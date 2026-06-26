import 'package:json_annotation/json_annotation.dart';

part 'note.g.dart';

@JsonSerializable()
class Note {
  final String id;
  final String videoId;
  final String title;
  final String contentMd;
  final String? transcriptJson;
  final DateTime createdAt;
  
  const Note({
    required this.id,
    required this.videoId,
    required this.title,
    required this.contentMd,
    this.transcriptJson,
    required this.createdAt,
  });
  
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
  
  Note copyWith({
    String? id,
    String? videoId,
    String? title,
    String? contentMd,
    String? transcriptJson,
    DateTime? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      contentMd: contentMd ?? this.contentMd,
      transcriptJson: transcriptJson ?? this.transcriptJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
