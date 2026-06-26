import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/ffmpeg_service.dart';
import 'package:keeji/core/exceptions.dart';
import 'package:keeji/database/app_database.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';
import 'package:keeji/services/asr_service.dart';
import 'package:keeji/services/llm_service.dart';

class VideoProcessor {
  static final VideoProcessor _instance = VideoProcessor._();
  factory VideoProcessor() => _instance;
  VideoProcessor._();
  
  final _ffmpeg = FFmpegService();
  final _asr = ASRService();
  final _llm = LLMService();
  final _db = AppDatabase();
  
  bool _isProcessing = false;
  
  Future<void> processVideo({
    required VideoRecord video,
    void Function(double progress, String stage)? onProgress,
  }) async {
    if (_isProcessing) {
      throw const KeejiException('已有视频正在处理中');
    }
    
    _isProcessing = true;
    final tempFiles = <String>[];
    
    try {
      // 更新状态为处理中
      await _db.updateVideo(video.copyWith(
        status: VideoStatus.processing,
        progress: 0.0,
      ));
      
      // 1. 提取音频
      onProgress?.call(0.1, '提取音频');
      final tempDir = await getTemporaryDirectory();
      final audioPath = path.join(tempDir.path, '${video.id}.wav');
      tempFiles.add(audioPath);
      
      await _ffmpeg.extractAudio(
        videoPath: video.filePath,
        outputPath: audioPath,
      );
      
      await _db.updateVideo(video.copyWith(progress: 0.3));
      
      // 2. 语音转写
      onProgress?.call(0.3, '语音转写');
      List<TranscriptSegment> segments;
      
      try {
        segments = await _asr.transcribeWithTimestamps(
          audioPath: audioPath,
          onProgress: (progress) {
            _db.updateVideo(video.copyWith(
              progress: 0.3 + progress * 0.4,
            ));
          },
        );
      } catch (e) {
        // 如果带时间戳的转写失败，尝试普通转写
        final text = await _asr.transcribeFile(audioPath: audioPath);
        segments = [TranscriptSegment(start: 0, end: 0, text: text)];
      }
      
      await _db.updateVideo(video.copyWith(progress: 0.7));
      
      // 3. 生成笔记
      onProgress?.call(0.7, '生成笔记');
      final transcriptText = segments.map((s) => s.text).join('\n');
      final note = await _llm.generateNote(
        transcript: transcriptText,
        videoTitle: video.filename,
      );
      
      await _db.updateVideo(video.copyWith(progress: 0.9));
      
      // 4. 保存笔记
      onProgress?.call(0.9, '保存笔记');
      final noteId = const Uuid().v4();
      await _db.insertNote(Note(
        id: noteId,
        videoId: video.id,
        title: note.title,
        contentMd: note.content,
        transcriptJson: jsonEncode(segments.map((s) => s.toJson()).toList()),
        createdAt: DateTime.now(),
      ));
      
      // 5. 更新状态为完成
      await _db.updateVideo(video.copyWith(
        status: VideoStatus.done,
        progress: 1.0,
      ));
      
      onProgress?.call(1.0, '完成');
    } catch (e) {
      // 更新状态为失败
      await _db.updateVideo(video.copyWith(
        status: VideoStatus.failed,
        error: e.toString(),
      ));
      rethrow;
    } finally {
      // 清理临时文件
      await _ffmpeg.cleanupTempFiles(tempFiles);
      _isProcessing = false;
    }
  }
  
  Future<void> retryProcessing({
    required VideoRecord video,
    void Function(double progress, String stage)? onProgress,
  }) async {
    // 删除旧笔记（如果有）
    final oldNote = await _db.getNoteByVideoId(video.id);
    if (oldNote != null) {
      await _db.deleteNote(oldNote.id);
    }
    
    // 重新处理
    await processVideo(
      video: video.copyWith(status: VideoStatus.pending, progress: 0.0, error: null),
      onProgress: onProgress,
    );
  }
}
