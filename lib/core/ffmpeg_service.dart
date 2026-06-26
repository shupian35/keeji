import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/exceptions.dart';

class FFmpegService {
  static final FFmpegService _instance = FFmpegService._();
  factory FFmpegService() => _instance;
  FFmpegService._();
  
  Future<String> get ffmpegPath async {
    if (Platform.isWindows) {
      // Windows: 检查系统 ffmpeg 或捆绑的 ffmpeg
      final systemPath = await _which('ffmpeg');
      if (systemPath != null) return systemPath;
      throw const FFmpegException('未找到 ffmpeg，请先安装 ffmpeg');
    } else if (Platform.isMacOS) {
      // macOS: 检查 /usr/local/bin 或 brew 安装
      final brewPath = '/usr/local/bin/ffmpeg';
      if (await File(brewPath).exists()) return brewPath;
      final systemPath = await _which('ffmpeg');
      if (systemPath != null) return systemPath;
      throw const FFmpegException('未找到 ffmpeg，请运行: brew install ffmpeg');
    } else {
      // Linux: 检查系统 ffmpeg
      final systemPath = await _which('ffmpeg');
      if (systemPath != null) return systemPath;
      throw const FFmpegException('未找到 ffmpeg，请安装 ffmpeg');
    }
  }
  
  Future<String?> _which(String command) async {
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        [command],
      );
      if (result.exitCode == 0) {
        return result.stdout.toString().trim().split('\n').first.trim();
      }
    } catch (_) {}
    return null;
  }
  
  Future<double> getAudioDuration(String filePath) async {
    final ffmpeg = await ffmpegPath;
    final ffprobe = ffmpeg.replaceAll('ffmpeg', 'ffprobe');
    
    final result = await Process.run(ffprobe, [
      '-v', 'error',
      '-show_entries', 'format=duration',
      '-of', 'default=noprint_wrappers=1:nokey=1',
      filePath,
    ]);
    
    if (result.exitCode != 0) {
      throw FFmpegException('获取音频时长失败: ${result.stderr}');
    }
    
    return double.tryParse(result.stdout.toString().trim()) ?? 0.0;
  }
  
  Future<String> extractAudio({
    required String videoPath,
    required String outputPath,
    void Function(double progress)? onProgress,
  }) async {
    final ffmpeg = await ffmpegPath;
    
    final result = await Process.run(ffmpeg, [
      '-i', videoPath,
      '-vn',
      '-acodec', 'pcm_s16le',
      '-ar', '${AppConstants.audioSampleRate}',
      '-ac', '${AppConstants.audioChannels}',
      '-y',
      outputPath,
    ]);
    
    if (result.exitCode != 0) {
      throw FFmpegException('音频提取失败: ${result.stderr}');
    }
    
    return outputPath;
  }
  
  Future<List<double>> detectSilencePoints({
    required String audioPath,
    double threshold = AppConstants.silenceThreshold,
    double duration = AppConstants.silenceDuration,
  }) async {
    final ffmpeg = await ffmpegPath;
    
    final result = await Process.run(ffmpeg, [
      '-i', audioPath,
      '-af', 'silencedetect=noise=${threshold}dB:d=$duration',
      '-f', 'null',
      '-',
    ]);
    
    final stderr = result.stderr.toString();
    final silencePoints = <double>[];
    
    final regex = RegExp(r'silence_start: (\d+\.?\d*)');
    for (final match in regex.allMatches(stderr)) {
      final start = double.tryParse(match.group(1) ?? '0') ?? 0;
      silencePoints.add(start);
    }
    
    return silencePoints;
  }
  
  Future<List<String>> splitAudioBySilence({
    required String audioPath,
    required String outputDir,
    double maxDurationMinutes = AppConstants.maxChunkDurationMinutes,
    void Function(double progress)? onProgress,
  }) async {
    final ffmpeg = await ffmpegPath;
    final duration = await getAudioDuration(audioPath);
    final silencePoints = await detectSilencePoints(audioPath: audioPath);
    
    final maxDuration = maxDurationMinutes * 60.0;
    final chunks = <String>[];
    
    double chunkStart = 0;
    int chunkIndex = 0;
    
    for (int i = 0; i <= silencePoints.length; i++) {
      final chunkEnd = i < silencePoints.length ? silencePoints[i] : duration;
      final chunkDuration = chunkEnd - chunkStart;
      
      if (chunkDuration >= maxDuration || i == silencePoints.length) {
        final outputPath = path.join(outputDir, 'chunk_${chunkIndex.toString().padLeft(3, '0')}.wav');
        
        await Process.run(ffmpeg, [
          '-i', audioPath,
          '-ss', '$chunkStart',
          '-t', '$chunkDuration',
          '-c', 'copy',
          '-y',
          outputPath,
        ]);
        
        chunks.add(outputPath);
        chunkStart = chunkEnd;
        chunkIndex++;
        
        onProgress?.call(chunkEnd / duration);
      }
    }
    
    return chunks;
  }
  
  Future<void> cleanupTempFiles(List<String> files) async {
    for (final file in files) {
      try {
        await File(file).delete();
      } catch (_) {}
    }
  }
}
