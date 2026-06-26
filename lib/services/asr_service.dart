import 'package:dio/dio.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ASRService {
  static final ASRService _instance = ASRService._();
  factory ASRService() => _instance;
  ASRService._();
  
  Dio? _dio;
  String _apiKey = '';
  String _baseUrl = AppConstants.defaultAsrBaseUrl;
  String _model = AppConstants.defaultAsrModel;
  bool _initialized = false;
  
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('asr_api_key') ?? '';
    _baseUrl = prefs.getString('asr_base_url') ?? AppConstants.defaultAsrBaseUrl;
    _model = prefs.getString('asr_model') ?? AppConstants.defaultAsrModel;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
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
      await prefs.setString('asr_api_key', apiKey);
    }
    if (baseUrl != null) {
      _baseUrl = baseUrl;
      await prefs.setString('asr_base_url', baseUrl);
    }
    if (model != null) {
      _model = model;
      await prefs.setString('asr_model', model);
    }
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    ));
    
    _initialized = true;
  }
  
  Future<String> testConnection() async {
    await _ensureInitialized();
    
    if (_apiKey.isEmpty) {
      return '请先配置 ASR API Key';
    }
    
    try {
      final response = await _dio!.get('/models');
      if (response.statusCode == 200) {
        return 'success';
      }
      return '连接失败: HTTP ${response.statusCode}';
    } on DioException catch (e) {
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
      return '连接失败: $e';
    }
  }
  
  Future<String> transcribeFile({
    required String audioPath,
    void Function(double progress)? onProgress,
  }) async {
    await _ensureInitialized();
    
    if (_apiKey.isEmpty) {
      throw const ASRException('请先配置 ASR API Key');
    }
    
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath),
        'model': _model,
        'language': 'zh',
      });
      
      final response = await _dio!.post(
        '/audio/transcriptions',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
          }
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['text'] ?? '';
      } else {
        throw ASRException('转写失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ASRException('转写请求失败: ${e.message}');
    }
  }
}
