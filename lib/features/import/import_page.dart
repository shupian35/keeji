import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_importType == ImportType.video ? l10n.importVideo : l10n.importText),
        actions: [
          TextButton.icon(
            onPressed: _isImporting ? null : _toggleImportType,
            icon: Icon(_importType == ImportType.video ? Icons.text_snippet : Icons.video_library),
            label: Text(_importType == ImportType.video ? l10n.switchToTextImport : l10n.switchToVideoImport),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilePicker(l10n),
            const SizedBox(height: 24),
            if (_selectedFiles.isNotEmpty) ...[
              _buildFileList(l10n),
              const SizedBox(height: 16),
              _buildOptions(l10n),
              const SizedBox(height: 24),
              _buildImportButton(l10n),
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
  
  Widget _buildFilePicker(AppLocalizations l10n) {
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
            isVideo ? l10n.selectVideoFiles : l10n.selectTextFiles,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supportedFormats(extensions.join(", ")),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isImporting ? null : _pickFiles,
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.selectFiles),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFileList(AppLocalizations l10n) {
    final isVideo = _importType == ImportType.video;
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectedFiles(_selectedFiles.length),
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
  
  Widget _buildOptions(AppLocalizations l10n) {
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
              child: Text(isVideo ? l10n.importAfterSelect : l10n.importTextAfterSelect),
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
  
  Widget _buildImportButton(AppLocalizations l10n) {
    final isVideo = _importType == ImportType.video;
    
    if (_isImporting) {
      return Column(
        children: [
          LinearProgressIndicator(
            value: _importTotal > 0 ? _importProgress / _importTotal : null,
          ),
          const SizedBox(height: 8),
          Text('${l10n.importing} $_importProgress/$_importTotal'),
        ],
      );
    }
    
    return FilledButton.icon(
      onPressed: _importFiles,
      icon: const Icon(Icons.add),
      label: Text(isVideo
          ? l10n.importVideos(_selectedFiles.length)
          : l10n.importTexts(_selectedFiles.length)),
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
    final l10n = AppLocalizations.of(context)!;
    bool shouldProcess = _startProcessing;
    
    if (shouldProcess) {
      final configValid = await _checkApiConfig();
      if (!configValid && mounted) {
        final importOnly = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.importOnly),
            content: Text(l10n.importOnlyHint),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.importOnly),
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
            sourceType: SourceType.video,
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
          SnackBar(content: Text(l10n.importSuccess(videos.length))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ErrorHandler.showError(context, e, title: l10n.importFailed);
      }
    }
  }
  
  Future<void> _importTextFiles() async {
    final l10n = AppLocalizations.of(context)!;
    bool shouldGenerate = _startProcessing;
    
    if (shouldGenerate) {
      final configValid = await _checkLlmConfig();
      if (!configValid && mounted) {
        final importOnly = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.importOnly),
            content: Text(l10n.importOnlyHint),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.importOnly),
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
              sourceType: SourceType.text,
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
          SnackBar(content: Text(l10n.importSuccess(successCount))),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ErrorHandler.showError(context, e, title: l10n.importFailed);
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
