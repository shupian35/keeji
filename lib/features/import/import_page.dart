import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/features/home/widgets/video_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ImportType { video, text }

class ImportPage extends ConsumerStatefulWidget {
  final ImportType importType;
  
  const ImportPage({super.key, this.importType = ImportType.video});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  final List<String> _selectedFiles = [];
  bool _startProcessing = true;
  bool _isImporting = false;
  int _importProgress = 0;
  int _importTotal = 0;
  late ImportType _importType;
  
  @override
  void initState() {
    super.initState();
    _importType = widget.importType;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_importType == ImportType.video ? '导入视频' : '导入原文'),
        actions: [
          TextButton.icon(
            onPressed: _isImporting ? null : _toggleImportType,
            icon: Icon(_importType == ImportType.video ? Icons.text_snippet : Icons.video_library),
            label: Text(_importType == ImportType.video ? '切换到导入原文' : '切换到导入视频'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilePicker(),
            const SizedBox(height: 24),
            if (_selectedFiles.isNotEmpty) ...[
              _buildFileList(),
              const SizedBox(height: 16),
              _buildOptions(),
              const SizedBox(height: 24),
              _buildImportButton(),
            ],
          ],
        ),
      ),
    );
  }
  
  void _toggleImportType() {
    setState(() {
      _selectedFiles.clear();
      _importType = _importType == ImportType.video ? ImportType.text : ImportType.video;
    });
  }
  
  Widget _buildFilePicker() {
    final isVideo = _importType == ImportType.video;
    final extensions = isVideo
        ? AppConstants.videoExtensions.map((e) => e.replaceFirst('.', '')).toList()
        : ['txt', 'md', 'text', 'srt', 'vtt'];
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVideo ? Icons.cloud_upload_outlined : Icons.text_snippet_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isVideo ? '选择视频文件' : '选择原文文件',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '支持 ${extensions.join(", ")}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isImporting ? null : _pickFiles,
            icon: const Icon(Icons.folder_open),
            label: const Text('选择文件'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFileList() {
    final isVideo = _importType == ImportType.video;
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已选择 ${_selectedFiles.length} 个文件',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final filePath = _selectedFiles[index];
                final fileName = filePath.split(Platform.pathSeparator).last;
                return ListTile(
                  leading: Icon(isVideo ? Icons.video_file : Icons.text_snippet),
                  title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _isImporting
                        ? null
                        : () {
                            setState(() => _selectedFiles.removeAt(index));
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptions() {
    final isVideo = _importType == ImportType.video;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isVideo ? Icons.play_circle_outline : Icons.auto_awesome,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(isVideo ? '导入后立即开始处理' : '导入后立即生成笔记'),
            ),
            Switch(
              value: _startProcessing,
              onChanged: _isImporting
                  ? null
                  : (value) {
                      setState(() => _startProcessing = value);
                    },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImportButton() {
    final isVideo = _importType == ImportType.video;
    
    if (_isImporting) {
      return Column(
        children: [
          LinearProgressIndicator(
            value: _importTotal > 0 ? _importProgress / _importTotal : null,
          ),
          const SizedBox(height: 8),
          Text('导入中 $_importProgress/$_importTotal'),
        ],
      );
    }
    
    return FilledButton.icon(
      onPressed: _importFiles,
      icon: const Icon(Icons.add),
      label: Text(isVideo
          ? '导入 ${_selectedFiles.length} 个视频'
          : '导入 ${_selectedFiles.length} 个原文'),
    );
  }
  
  Future<void> _pickFiles() async {
    final isVideo = _importType == ImportType.video;
    final extensions = isVideo
        ? AppConstants.videoExtensions.map((e) => e.replaceFirst('.', '')).toList()
        : ['txt', 'md', 'text', 'srt', 'vtt'];
    
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: true,
    );
    
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.whereType<String>());
      });
    }
  }
  
  Future<void> _importFiles() async {
    if (_importType == ImportType.video) {
      await _importVideoFiles();
    } else {
      await _importTextFiles();
    }
  }
  
  Future<void> _importVideoFiles() async {
    bool shouldProcess = _startProcessing;
    
    if (shouldProcess) {
      final configValid = await _checkApiConfig();
      if (!configValid && mounted) {
        final importOnly = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('是否只导入？'),
            content: const Text('API 配置不完整，无法自动处理视频。\n是否只导入视频，稍后再处理？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('只导入'),
              ),
            ],
          ),
        );
        
        if (importOnly != true) return;
        shouldProcess = false;
      }
    }
    
    setState(() {
      _isImporting = true;
      _importTotal = _selectedFiles.length;
      _importProgress = 0;
    });
    
    final db = ref.read(databaseProvider);
    final videos = <VideoRecord>[];
    const batchSize = 10;
    
    try {
      // 分批处理文件
      for (int i = 0; i < _selectedFiles.length; i += batchSize) {
        final end = (i + batchSize).clamp(0, _selectedFiles.length);
        final batch = _selectedFiles.sublist(i, end);
        
        for (final filePath in batch) {
          final video = VideoRecord(
            id: const Uuid().v4(),
            filename: filePath.split(Platform.pathSeparator).last,
            filePath: filePath,
            status: VideoStatus.pending,
            createdAt: DateTime.now(),
          );
          await db.insertVideo(video);
          videos.add(video);
        }
        
        // 更新进度并让UI有机会刷新
        setState(() {
          _importProgress = end;
        });
        
        // 让出控制权给UI线程
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      if (shouldProcess && videos.isNotEmpty) {
        _startProcessingVideos(videos);
      }
      
      ref.read(videoListProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${videos.length} 个视频')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ErrorHandler.showError(context, e, title: '导入失败');
      }
    }
  }
  
  Future<void> _importTextFiles() async {
    bool shouldGenerate = _startProcessing;
    
    if (shouldGenerate) {
      final configValid = await _checkLlmConfig();
      if (!configValid && mounted) {
        final importOnly = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('是否只导入？'),
            content: const Text('LLM 配置不完整，无法自动生成笔记。\n是否只导入原文，稍后再生成？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('只导入'),
              ),
            ],
          ),
        );
        
        if (importOnly != true) return;
        shouldGenerate = false;
      }
    }
    
    setState(() {
      _isImporting = true;
      _importTotal = _selectedFiles.length;
      _importProgress = 0;
    });
    
    final db = ref.read(databaseProvider);
    final llmService = ref.read(llmServiceProvider);
    int successCount = 0;
    const batchSize = 5;
    
    try {
      // 分批处理文件
      for (int i = 0; i < _selectedFiles.length; i += batchSize) {
        final end = (i + batchSize).clamp(0, _selectedFiles.length);
        final batch = _selectedFiles.sublist(i, end);
        
        for (final filePath in batch) {
          try {
            final file = File(filePath);
            final content = await file.readAsString();
            final fileName = filePath.split(Platform.pathSeparator).last;
            
            final video = VideoRecord(
              id: const Uuid().v4(),
              filename: fileName,
              filePath: filePath,
              status: VideoStatus.done,
              createdAt: DateTime.now(),
            );
            await db.insertVideo(video);
            
            if (shouldGenerate && content.isNotEmpty) {
              final note = await llmService.generateNote(
                transcript: content,
                videoTitle: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
              );
              
              await db.insertNote(Note(
                id: const Uuid().v4(),
                videoId: video.id,
                title: note.title,
                contentMd: note.content,
                transcriptJson: content,
                createdAt: DateTime.now(),
              ));
            } else {
              await db.insertNote(Note(
                id: const Uuid().v4(),
                videoId: video.id,
                title: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
                contentMd: content,
                transcriptJson: content,
                createdAt: DateTime.now(),
              ));
            }
            
            successCount++;
          } catch (e) {
            debugPrint('处理文件失败: $e');
          }
        }
        
        // 更新进度并让UI有机会刷新
        setState(() {
          _importProgress = end;
        });
        
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      ref.read(videoListProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 $successCount 个文件')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ErrorHandler.showError(context, e, title: '导入失败');
      }
    }
  }
  
  Future<bool> _checkApiConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final asrKey = prefs.getString('asr_api_key') ?? '';
    final llmKey = prefs.getString('llm_api_key') ?? '';
    
    return asrKey.isNotEmpty && llmKey.isNotEmpty;
  }
  
  Future<bool> _checkLlmConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final llmKey = prefs.getString('llm_api_key') ?? '';
    
    return llmKey.isNotEmpty;
  }
  
  void _startProcessingVideos(List<VideoRecord> videos) {
    final processor = ref.read(videoProcessorProvider);
    
    for (final video in videos) {
      processor.processVideo(video: video).catchError((e) {
        debugPrint('处理视频失败: $e');
      });
    }
  }
}
