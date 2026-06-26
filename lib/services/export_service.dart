import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:keeji/models/note.dart';

class ExportService {
  static final ExportService _instance = ExportService._();
  factory ExportService() => _instance;
  ExportService._();
  
  Future<String?> exportNoteAsMarkdown(Note note) async {
    final fileName = '${_sanitizeFileName(note.title)}.md';
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 桌面端：打开文件保存对话框
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存笔记',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['md'],
      );
      
      if (outputPath == null) return null;
      
      await File(outputPath).writeAsString(note.contentMd);
      return outputPath;
    } else {
      // 移动端：保存到应用目录并分享
      final dir = await getApplicationDocumentsDirectory();
      final file = File(path.join(dir.path, 'exports', fileName));
      
      await file.parent.create(recursive: true);
      await file.writeAsString(note.contentMd);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: fileName,
      );
      
      return file.path;
    }
  }
  
  Future<String?> exportTranscriptAsText(Note note) async {
    final fileName = '${_sanitizeFileName(note.title)}_转写.txt';
    
    // 获取转写文本
    String text = note.contentMd;
    if (note.transcriptJson != null && note.transcriptJson!.isNotEmpty) {
      text = note.transcriptJson!;
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 桌面端：打开文件保存对话框
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存转写原文',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      
      if (outputPath == null) return null;
      
      await File(outputPath).writeAsString(text);
      return outputPath;
    } else {
      // 移动端：保存到应用目录并分享
      final dir = await getApplicationDocumentsDirectory();
      final file = File(path.join(dir.path, 'exports', fileName));
      
      await file.parent.create(recursive: true);
      await file.writeAsString(text);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: fileName,
      );
      
      return file.path;
    }
  }
  
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length.clamp(0, 50));
  }
}
