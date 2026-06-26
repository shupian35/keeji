import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LLMService {
  static final LLMService _instance = LLMService._();
  factory LLMService() => _instance;
  LLMService._();
  
  late Dio _dio;
  String _apiKey = '';
  String _baseUrl = AppConstants.defaultLlmBaseUrl;
  String _model = AppConstants.defaultLlmModel;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('llm_api_key') ?? '';
    _baseUrl = prefs.getString('llm_base_url') ?? AppConstants.defaultLlmBaseUrl;
    _model = prefs.getString('llm_model') ?? AppConstants.defaultLlmModel;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }
  
  Future<void> updateConfig({
    String? apiKey,
    String? baseUrl,
    String? model,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (apiKey != null) {
      _apiKey = apiKey;
      await prefs.setString('llm_api_key', apiKey);
    }
    if (baseUrl != null) {
      _baseUrl = baseUrl;
      await prefs.setString('llm_base_url', baseUrl);
    }
    if (model != null) {
      _model = model;
      await prefs.setString('llm_model', model);
    }
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }
  
  Future<void> testConnection({
    required String apiKey,
    required String baseUrl,
  }) async {
    final testDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
    ));
    
    try {
      final response = await testDio.get('/models');
      if (response.statusCode != 200) {
        throw LLMException('连接失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const LLMException('API Key 无效');
      }
      throw LLMException('连接失败: ${e.message}');
    }
  }
  
  Future<GeneratedNote> generateNote({
    required String transcript,
    String? videoTitle,
    void Function(double progress)? onProgress,
  }) async {
    if (_apiKey.isEmpty) {
      throw const LLMException('请先配置 LLM API Key');
    }
    
    final prompt = _buildPrompt(transcript, videoTitle);
    
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的笔记助手，擅长将语音转写文本整理成结构化的 Markdown 笔记。',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 4096,
        },
      );
      
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return _parseResponse(content);
      } else {
        throw LLMException('生成笔记失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw LLMException('生成笔记请求失败: ${e.message}');
    }
  }
  
  String _buildPrompt(String transcript, String? videoTitle) {
    return '''请根据以下语音转写文本，生成一份结构化的 Markdown 笔记。

要求：
1. 提取核心知识点和要点
2. 使用清晰的层级结构（标题、列表）
3. 保留重要的原文引用
4. 添加适当的总结

${videoTitle != null ? '视频标题：$videoTitle\n' : ''}
转写文本：
$transcript

请以 JSON 格式返回，包含以下字段：
{
  "title": "笔记标题",
  "content": "Markdown 格式的笔记内容"
}''';
  }
  
  GeneratedNote _parseResponse(String content) {
    try {
      // 尝试直接解析 JSON
      final json = jsonDecode(content);
      return GeneratedNote(
        title: json['title'] ?? '未命名笔记',
        content: json['content'] ?? content,
      );
    } catch (_) {
      // 尝试从代码块中提取 JSON
      final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
      final match = codeBlockRegex.firstMatch(content);
      if (match != null) {
        try {
          final json = jsonDecode(match.group(1)!);
          return GeneratedNote(
            title: json['title'] ?? '未命名笔记',
            content: json['content'] ?? content,
          );
        } catch (_) {}
      }
      
      // 尝试从花括号中提取 JSON
      final braceRegex = RegExp(r'\{[\s\S]*\}');
      final braceMatch = braceRegex.firstMatch(content);
      if (braceMatch != null) {
        try {
          final json = jsonDecode(braceMatch.group(0)!);
          return GeneratedNote(
            title: json['title'] ?? '未命名笔记',
            content: json['content'] ?? content,
          );
        } catch (_) {}
      }
      
      // 如果都失败，返回原文作为内容
      return GeneratedNote(
        title: '未命名笔记',
        content: content,
      );
    }
  }
}

class GeneratedNote {
  final String title;
  final String content;
  
  const GeneratedNote({
    required this.title,
    required this.content,
  });
}
