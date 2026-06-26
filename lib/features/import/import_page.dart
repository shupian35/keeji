import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/core/constants.dart';

class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  final List<String> _selectedFiles = [];
  
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
            onPressed: _pickFiles,
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
                    onPressed: () {
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
  
  Widget _buildImportButton() {
    return FilledButton.icon(
      onPressed: _importFiles,
      icon: const Icon(Icons.add),
      label: Text('导入 ${_selectedFiles.length} 个视频'),
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
    final db = ref.read(databaseProvider);
    
    for (final filePath in _selectedFiles) {
      final video = VideoRecord(
        id: const Uuid().v4(),
        filename: filePath.split(Platform.pathSeparator).last,
        filePath: filePath,
        status: VideoStatus.pending,
        createdAt: DateTime.now(),
      );
      await db.insertVideo(video);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
