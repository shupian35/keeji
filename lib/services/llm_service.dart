import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LLMService {
  static final LLMService _instance = LLMService._();
  factory LLMService() => _instance;
  LLMService._();
  
  Dio? _dio;
  String _apiKey = '';
  String _baseUrl = AppConstants.defaultLlmBaseUrl;
  String _model = AppConstants.defaultLlmModel;
  bool _initialized = false;
  
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
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
    
    _initialized = true;
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
    
    _initialized = true;
  }
  
  Future<String> testConnection({String? modelNotFoundMessage}) async {
    await _ensureInitialized();
    
    if (_apiKey.isEmpty) {
      return '请先配置 LLM API Key';
    }
    
    try {
      log('LLM testConnection: baseUrl=$_baseUrl, model=$_model');
      final response = await _dio!.get('/models');
      log('LLM testConnection response: statusCode=${response.statusCode}, data=${response.data}');
      if (response.statusCode == 200) {
        final models = response.data['data'] as List?;
        if (models != null) {
          final modelIds = models.map((m) => m['id'].toString()).toList();
          if (!modelIds.contains(_model)) {
            return modelNotFoundMessage ?? '模型不存在: $_model';
          }
        }
        return 'success';
      }
      return response.data.toString();
    } on DioException catch (e) {
      log('LLM testConnection error: statusCode=${e.response?.statusCode}, message=${e.message}');
      if (e.response?.statusCode == 401) {
        return 'API Key 无效';
      }
      if (e.response?.statusCode == 403) {
        return 'API Key 权限不足';
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        return '连接超时，请检查网络';
      }
      if (e.type == DioExceptionType.connectionError) {
        return '无法连接到服务器，请检查 API 地址';
      }
      return '连接失败: ${e.message}';
    } catch (e) {
      log('LLM testConnection exception: $e');
      return '连接失败: $e';
    }
  }
  
  Future<GeneratedNote> generateNote({
    required String transcript,
    String? videoTitle,
    void Function(double progress)? onProgress,
  }) async {
    await _ensureInitialized();
    
    if (_apiKey.isEmpty) {
      throw const LLMException('请先配置 LLM API Key');
    }
    
    final prompt = _buildPrompt(transcript, videoTitle);
    
    try {
      final response = await _dio!.post(
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
        
        // 检查是否返回了 HTML
        if (content is String && (content.trimLeft().startsWith('<!DOCTYPE') || content.trimLeft().startsWith('<html'))) {
          throw const LLMException('API 返回了 HTML 页面，请检查 API 地址是否正确');
        }
        
        return _parseResponse(content);
      } else {
        throw LLMException('生成笔记失败: ${response.statusCode}');
      }
    } on LLMException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const LLMException('API Key 无效');
      }
      throw LLMException('生成笔记请求失败: ${e.message}');
    } catch (e) {
      throw LLMException('生成笔记失败: $e');
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
    // 检查是否是 HTML
    if (content.trimLeft().startsWith('<!DOCTYPE') || content.trimLeft().startsWith('<html')) {
      throw const LLMException('API 返回了 HTML 页面，请检查 API 地址是否正确');
    }
    
    try {
      final json = jsonDecode(content);
      return GeneratedNote(
        title: json['title'] ?? '未命名笔记',
        content: json['content'] ?? content,
      );
    } catch (_) {
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
