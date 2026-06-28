// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoRecord _$VideoRecordFromJson(Map<String, dynamic> json) => VideoRecord(
  id: json['id'] as String,
  filename: json['filename'] as String,
  filePath: json['filePath'] as String,
  sourceType:
      $enumDecodeNullable(_$SourceTypeEnumMap, json['sourceType']) ??
      SourceType.video,
  status:
      $enumDecodeNullable(_$VideoStatusEnumMap, json['status']) ??
      VideoStatus.pending,
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  error: json['error'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$VideoRecordToJson(VideoRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename': instance.filename,
      'filePath': instance.filePath,
      'sourceType': _$SourceTypeEnumMap[instance.sourceType]!,
      'status': _$VideoStatusEnumMap[instance.status]!,
      'progress': instance.progress,
      'error': instance.error,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SourceTypeEnumMap = {
  SourceType.video: 'video',
  SourceType.text: 'text',
};

const _$VideoStatusEnumMap = {
  VideoStatus.pending: 'pending',
  VideoStatus.processing: 'processing',
  VideoStatus.done: 'done',
  VideoStatus.failed: 'failed',
};
