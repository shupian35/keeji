import 'package:dio/dio.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ASRService {
  static final ASRService _instance = ASRService._();
  factory ASRService() => _instance;
  ASRService._();
  
  late Dio _dio;
  String _apiKey = '';
  String _baseUrl = AppConstants.defaultAsrBaseUrl;
  String _model = AppConstants.defaultAsrModel;
  
  Future<void> init() async {
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
  }
  
  Future<void> testConnection({
    required String apiKey,
    required String baseUrl,
  }) async {
    final testDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    ));
    
    try {
      final response = await testDio.get('/models');
      if (response.statusCode != 200) {
        throw ASRException('连接失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ASRException('API Key 无效');
      }
      throw ASRException('连接失败: ${e.message}');
    }
  }
  
  Future<String> transcribeFile({
    required String audioPath,
    void Function(double progress)? onProgress,
  }) async {
    if (_apiKey.isEmpty) {
      throw const ASRException('请先配置 ASR API Key');
    }
    
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath),
        'model': _model,
        'language': 'zh',
      });
      
      final response = await _dio.post(
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
  
  Future<List<TranscriptSegment>> transcribeWithTimestamps({
    required String audioPath,
    void Function(double progress)? onProgress,
  }) async {
    if (_apiKey.isEmpty) {
      throw const ASRException('请先配置 ASR API Key');
    }
    
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(audioPath),
        'model': _model,
        'language': 'zh',
        'response_format': 'verbose_json',
        'timestamp_granularities[]': 'segment',
      });
      
      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress?.call(sent / total);
          }
        },
      );
      
      if (response.statusCode == 200) {
        final segments = <TranscriptSegment>[];
        for (final seg in response.data['segments'] ?? []) {
          segments.add(TranscriptSegment(
            start: (seg['start'] as num).toDouble(),
            end: (seg['end'] as num).toDouble(),
            text: seg['text'] ?? '',
          ));
        }
        return segments;
      } else {
        throw ASRException('转写失败: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ASRException('转写请求失败: ${e.message}');
    }
  }
}

class TranscriptSegment {
  final double start;
  final double end;
  final String text;
  
  const TranscriptSegment({
    required this.start,
    required this.end,
    required this.text,
  });
  
  Map<String, dynamic> toJson() => {
    'start': start,
    'end': end,
    'text': text,
  };
  
  factory TranscriptSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptSegment(
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] ?? '',
    );
  }
}
