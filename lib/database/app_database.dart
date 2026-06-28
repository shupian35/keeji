import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/app_path.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  AppDatabase._();
  
  Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final dir = await AppPath.getDataDir();
    final dbPath = path.join(dir, AppConstants.dbName);
    
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE video_records ADD COLUMN source_type INTEGER NOT NULL DEFAULT 0",
      );
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE video_records (
        id TEXT PRIMARY KEY,
        filename TEXT NOT NULL,
        file_path TEXT NOT NULL,
        source_type INTEGER NOT NULL DEFAULT 0,
        status INTEGER NOT NULL DEFAULT 0,
        progress REAL NOT NULL DEFAULT 0.0,
        error TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        video_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content_md TEXT NOT NULL,
        transcript_json TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (video_id) REFERENCES video_records (id)
      )
    ''');
  }
  
  // 视频记录操作
  Future<List<VideoRecord>> getAllVideos() async {
    final db = await database;
    final maps = await db.query('video_records', orderBy: 'created_at DESC');
    return maps.map(_videoFromMap).toList();
  }
  
  Future<VideoRecord?> getVideoById(String id) async {
    final db = await database;
    final maps = await db.query(
      'video_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _videoFromMap(maps.first);
  }
  
  Stream<VideoRecord?> watchVideoById(String id) async* {
    while (true) {
      yield await getVideoById(id);
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  
  Future<void> insertVideo(VideoRecord video) async {
    final db = await database;
    await db.insert('video_records', _videoToMap(video));
  }
  
  Future<void> updateVideo(VideoRecord video) async {
    final db = await database;
    await db.update(
      'video_records',
      _videoToMap(video),
      where: 'id = ?',
      whereArgs: [video.id],
    );
  }
  
  Future<void> deleteVideo(String id) async {
    final db = await database;
    await db.delete('video_records', where: 'id = ?', whereArgs: [id]);
  }
  
  VideoRecord _videoFromMap(Map<String, dynamic> map) {
    return VideoRecord(
      id: map['id'] as String,
      filename: map['filename'] as String,
      filePath: map['file_path'] as String,
      sourceType: SourceType.values[map['source_type'] as int? ?? 0],
      status: VideoStatus.values[map['status'] as int],
      progress: (map['progress'] as num).toDouble(),
      error: map['error'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  
  Map<String, dynamic> _videoToMap(VideoRecord video) {
    return {
      'id': video.id,
      'filename': video.filename,
      'file_path': video.filePath,
      'source_type': video.sourceType.index,
      'status': video.status.index,
      'progress': video.progress,
      'error': video.error,
      'created_at': video.createdAt.toIso8601String(),
    };
  }
  
  // 笔记操作
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'created_at DESC');
    return maps.map(_noteFromMap).toList();
  }
  
  Future<Note?> getNoteByVideoId(String videoId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
    if (maps.isEmpty) return null;
    return _noteFromMap(maps.first);
  }
  
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', _noteToMap(note));
  }
  
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      _noteToMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
  
  Note _noteFromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      videoId: map['video_id'] as String,
      title: map['title'] as String,
      contentMd: map['content_md'] as String,
      transcriptJson: map['transcript_json'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  
  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'video_id': note.videoId,
      'title': note.title,
      'content_md': note.contentMd,
      'transcript_json': note.transcriptJson,
      'created_at': note.createdAt.toIso8601String(),
    };
  }
}
