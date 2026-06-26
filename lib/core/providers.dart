import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/database/app_database.dart';
import 'package:keeji/services/asr_service.dart';
import 'package:keeji/services/llm_service.dart';
import 'package:keeji/services/video_processor.dart';
import 'package:keeji/services/export_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final asrServiceProvider = Provider<ASRService>((ref) {
  return ASRService();
});

final llmServiceProvider = Provider<LLMService>((ref) {
  return LLMService();
});

final videoProcessorProvider = Provider<VideoProcessor>((ref) {
  return VideoProcessor();
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});
