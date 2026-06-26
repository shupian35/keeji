import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/features/home/widgets/video_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  final List<String> _selectedFiles = [];
  bool _startProcessing = true;
  bool _isImporting = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导入视频'),
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
  
  Widget _buildFilePicker() {
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
            Icons.cloud_upload_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '选择视频文件',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '支持 ${AppConstants.videoExtensions.join(", ")}',
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
                  leading: const Icon(Icons.video_file),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.play_circle_outline, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('导入后立即开始处理'),
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
    return FilledButton.icon(
      onPressed: _isImporting ? null : _importFiles,
      icon: _isImporting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      label: Text(_isImporting ? '导入中...' : '导入 ${_selectedFiles.length} 个视频'),
    );
  }
  
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.videoExtensions
          .map((e) => e.replaceFirst('.', ''))
          .toList(),
      allowMultiple: true,
    );
    
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.whereType<String>());
      });
    }
  }
  
  Future<void> _importFiles() async {
    bool shouldProcess = _startProcessing;
    
    // 如果选择立即处理，检查配置
    if (shouldProcess) {
      final configValid = await _checkApiConfig();
      if (!configValid) {
        // 配置不完整，询问是否只导入不处理
        final importOnly = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('是否只导入？'),
            content: const Text('API 配置不完整，无法自动处理视频。\n是否只导入视频，稍后再处理？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('只导入'),
              ),
            ],
          ),
        );
        
        if (importOnly != true) return;
        shouldProcess = false;
      }
    }
    
    setState(() => _isImporting = true);
    
    final db = ref.read(databaseProvider);
    final videos = <VideoRecord>[];
    
    try {
      for (final filePath in _selectedFiles) {
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
      
      if (shouldProcess && videos.isNotEmpty) {
        _startProcessingVideos(videos);
      }
      
      // 刷新首页视频列表
      ref.invalidate(videoListFutureProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 ${videos.length} 个视频')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }
  
  Future<bool> _checkApiConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final asrKey = prefs.getString('asr_api_key') ?? '';
    final llmKey = prefs.getString('llm_api_key') ?? '';
    
    return asrKey.isNotEmpty && llmKey.isNotEmpty;
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
