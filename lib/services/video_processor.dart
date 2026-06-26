import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/ffmpeg_service.dart';
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
  
  final _queue = <_QueueItem>[];
  bool _isProcessing = false;
  
  Future<void> processVideo({
    required VideoRecord video,
    void Function(double progress, String stage)? onProgress,
  }) async {
    // 将视频加入队列
    final completer = Completer<void>();
    _queue.add(_QueueItem(
      video: video,
      onProgress: onProgress,
      completer: completer,
    ));
    
    // 如果没有正在处理的任务，开始处理
    if (!_isProcessing) {
      _processQueue();
    }
    
    // 等待当前视频处理完成
    return completer.future;
  }
  
  Future<void> _processQueue() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }
    
    _isProcessing = true;
    final item = _queue.removeAt(0);
    
    try {
      await _processVideoItem(item);
      item.completer.complete();
    } catch (e) {
      item.completer.completeError(e);
    }
    
    // 继续处理队列中的下一个
    _processQueue();
  }
  
  Future<void> _processVideoItem(_QueueItem item) async {
    final video = item.video;
    final onProgress = item.onProgress;
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
      final transcriptText = await _asr.transcribeFile(
        audioPath: audioPath,
        onProgress: (progress) {
          _db.updateVideo(video.copyWith(
            progress: 0.3 + progress * 0.4,
          ));
        },
      );
      
      await _db.updateVideo(video.copyWith(progress: 0.7));
      
      // 3. 生成笔记
      onProgress?.call(0.7, '生成笔记');
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
        transcriptJson: transcriptText,
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
  
  int get queueLength => _queue.length;
  bool get isProcessing => _isProcessing;
}

class _QueueItem {
  final VideoRecord video;
  final void Function(double progress, String stage)? onProgress;
  final Completer<void> completer;
  
  _QueueItem({
    required this.video,
    this.onProgress,
    required this.completer,
  });
}
