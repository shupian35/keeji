import 'dart:io';
import 'package:archive/archive.dart';
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
    
    String text = note.contentMd;
    if (note.transcriptJson != null && note.transcriptJson!.isNotEmpty) {
      text = note.transcriptJson!;
    }
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  
  Future<String?> batchExportNotes(
    List<Note> notes, {
    bool exportNotes = true,
    bool exportTranscripts = false,
  }) async {
    if (notes.isEmpty) return null;
    
    final filesToExport = <String, String>{}; // fileName -> content
    
    for (final note in notes) {
      if (exportNotes) {
        final fileName = '${_sanitizeFileName(note.title)}.md';
        filesToExport[fileName] = note.contentMd;
      }
      if (exportTranscripts) {
        final fileName = '${_sanitizeFileName(note.title)}_转写.txt';
        String text = note.contentMd;
        if (note.transcriptJson != null && note.transcriptJson!.isNotEmpty) {
          text = note.transcriptJson!;
        }
        filesToExport[fileName] = text;
      }
    }
    
    if (filesToExport.isEmpty) return null;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // 桌面端：选择文件夹保存
      final outputDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择导出文件夹',
      );
      
      if (outputDir == null) return null;
      
      for (final entry in filesToExport.entries) {
        final file = File(path.join(outputDir, entry.key));
        await file.writeAsString(entry.value);
      }
      
      return outputDir;
    } else {
      // 移动端：打包成 ZIP 分享
      final dir = await getApplicationDocumentsDirectory();
      final zipDir = Directory(path.join(dir.path, 'exports', 'batch'));
      await zipDir.create(recursive: true);
      
      final archive = Archive();
      for (final entry in filesToExport.entries) {
        final content = entry.value.codeUnits;
        archive.addFile(ArchiveFile(entry.key, content.length, content));
      }
      
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      
      if (zipData == null) return null;
      
      final zipFile = File(path.join(zipDir.path, 'notes_export.zip'));
      await zipFile.writeAsBytes(zipData);
      
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        subject: '笔记导出',
      );
      
      return zipFile.path;
    }
  }
  
  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length.clamp(0, 50));
  }
}
