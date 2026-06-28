import 'dart:io';
import 'package:path/path.dart' as path;

class AppPath {
  static String? _appDir;
  
  static Future<String> getAppDir() async {
    if (_appDir != null) return _appDir!;
    
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final exePath = Platform.resolvedExecutable;
      _appDir = path.dirname(exePath);
    } else {
      final dir = Directory.current;
      _appDir = dir.path;
    }
    
    return _appDir!;
  }
  
  static Future<String> getDataDir() async {
    final appDir = await getAppDir();
    final dataDir = path.join(appDir, 'data');
    
    final dir = Directory(dataDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return dataDir;
  }
  
  static Future<String> getExportsDir() async {
    final dataDir = await getDataDir();
    final exportsDir = path.join(dataDir, 'exports');
    
    final dir = Directory(exportsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return exportsDir;
  }
}
