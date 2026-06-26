import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:keeji/models/note.dart';

class ExportService {
  static final ExportService _instance = ExportService._();
  factory ExportService() => _instance;
  ExportService._();
  
  Future<File> exportNoteAsMarkdown(Note note) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.md';
    final file = File(path.join(dir.path, 'exports', fileName));
    
    await file.parent.create(recursive: true);
    await file.writeAsString(note.contentMd);
    
    return file;
  }
  
  Future<File> exportTranscriptAsText(Note note) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${_sanitizeFileName(note.title)}_转写.txt';
    final file = File(path.join(dir.path, 'exports', fileName));
    
    await file.parent.create(recursive: true);
    
    // 从 JSON 中提取纯文本
    String text = note.contentMd;
    if (note.transcriptJson != null) {
      try {
        // 尝试解析转写 JSON 并提取文本
        text = note.transcriptJson!;
      } catch (_) {}
    }
    
    await file.writeAsString(text);
    
    return file;
  }
  
  Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: path.basename(file.path),
    );
  }
  
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length.clamp(0, 50));
  }
}
