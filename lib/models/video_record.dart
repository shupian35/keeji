import 'package:json_annotation/json_annotation.dart';

part 'video_record.g.dart';

enum VideoStatus {
  pending,
  processing,
  done,
  failed,
}

@JsonSerializable()
class VideoRecord {
  final String id;
  final String filename;
  final String filePath;
  final VideoStatus status;
  final double progress;
  final String? error;
  final DateTime createdAt;
  
  const VideoRecord({
    required this.id,
    required this.filename,
    required this.filePath,
    this.status = VideoStatus.pending,
    this.progress = 0.0,
    this.error,
    required this.createdAt,
  });
  
  factory VideoRecord.fromJson(Map<String, dynamic> json) => _$VideoRecordFromJson(json);
  Map<String, dynamic> toJson() => _$VideoRecordToJson(this);
  
  VideoRecord copyWith({
    String? id,
    String? filename,
    String? filePath,
    VideoStatus? status,
    double? progress,
    String? error,
    DateTime? createdAt,
  }) {
    return VideoRecord(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
