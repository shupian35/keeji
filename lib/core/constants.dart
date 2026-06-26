class AppConstants {
  static const String appName = '课记';
  static const String appVersion = '1.0.0';
  
  // 数据库
  static const String dbName = 'keeji.db';
  
  // 默认 ASR 配置
  static const String defaultAsrBaseUrl = 'https://api.siliconflow.cn/v1';
  static const String defaultAsrModel = 'FunAudioLLM/SenseVoiceSmall';
  
  // 默认 LLM 配置
  static const String defaultLlmBaseUrl = 'https://api.openai.com/v1';
  static const String defaultLlmModel = 'gpt-4o-mini';
  
  // 音频处理
  static const int audioSampleRate = 16000;
  static const int audioChannels = 1;
  static const double maxChunkDurationMinutes = 10.0;
  static const double silenceThreshold = -30.0;
  static const double silenceDuration = 0.5;
  
  // 文件扩展名
  static const List<String> videoExtensions = [
    '.mp4', '.avi', '.mov', '.mkv', '.flv', '.wmv', '.webm', '.m4v'
  ];
  
  static const List<String> audioExtensions = [
    '.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a'
  ];
}
