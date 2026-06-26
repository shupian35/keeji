// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  id: json['id'] as String,
  videoId: json['videoId'] as String,
  title: json['title'] as String,
  contentMd: json['contentMd'] as String,
  transcriptJson: json['transcriptJson'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'videoId': instance.videoId,
  'title': instance.title,
  'contentMd': instance.contentMd,
  'transcriptJson': instance.transcriptJson,
  'createdAt': instance.createdAt.toIso8601String(),
};
