import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';
import 'package:keeji/features/viewer/widgets/video_player_widget.dart';
import 'package:keeji/features/viewer/widgets/transcript_panel.dart';

final videoProvider = FutureProvider.family<VideoRecord?, String>((ref, videoId) async {
  final db = ref.watch(databaseProvider);
  return db.getVideoById(videoId);
});

final noteProvider = FutureProvider.family<Note?, String>((ref, videoId) async {
  final db = ref.watch(databaseProvider);
  return db.getNoteByVideoId(videoId);
});

class ViewerPage extends ConsumerStatefulWidget {
  final String videoId;
  
  const ViewerPage({super.key, required this.videoId});

  @override
  ConsumerState<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends ConsumerState<ViewerPage> {
  bool _showTranscript = false;
  bool _isRegenerating = false;
  
  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoProvider(widget.videoId));
    final noteAsync = ref.watch(noteProvider(widget.videoId));
    
    return videoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(child: Text('加载失败: $error')),
      ),
      data: (video) {
        if (video == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('未找到')),
            body: const Center(child: Text('视频记录不存在')),
          );
        }
        
        return noteAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(video.filename)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: Text(video.filename)),
            body: Center(child: Text('加载笔记失败: $error')),
          ),
          data: (note) {
            return _buildContent(video, note);
          },
        );
      },
    );
  }
  
  Widget _buildContent(VideoRecord video, Note? note) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note?.title ?? video.filename),
        actions: [
          IconButton(
            icon: Icon(_showTranscript ? Icons.description : Icons.description_outlined),
            onPressed: () => setState(() => _showTranscript = !_showTranscript),
            tooltip: '显示转写原文',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value, video, note),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_md',
                child: Text('导出笔记'),
              ),
              const PopupMenuItem(
                value: 'export_txt',
                child: Text('导出转写'),
              ),
              const PopupMenuItem(
                value: 'regenerate',
                child: Text('重新生成'),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 400,
            child: VideoPlayerWidget(videoPath: video.filePath),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: note != null
                ? Markdown(
                    data: note.contentMd,
                    padding: const EdgeInsets.all(16),
                    selectable: true,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        const Text('暂无笔记'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isRegenerating ? null : () => _regenerate(video),
                          icon: _isRegenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isRegenerating ? '生成中...' : '生成笔记'),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_showTranscript) ...[
            const VerticalDivider(width: 1),
            Container(
              width: 300,
              constraints: const BoxConstraints(minHeight: 200),
              child: TranscriptPanel(
                transcriptText: note?.transcriptJson,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _handleAction(String action, VideoRecord video, Note? note) async {
    switch (action) {
      case 'export_md':
        if (note != null) {
          await _exportMarkdown(note);
        }
        break;
      case 'export_txt':
        if (note != null) {
          await _exportTranscript(note);
        }
        break;
      case 'regenerate':
        await _regenerate(video);
        break;
    }
  }
  
  Future<void> _exportMarkdown(Note note) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      final outputPath = await exportService.exportNoteAsMarkdown(note);
      
      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('笔记已保存到: $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e, title: '导出失败');
      }
    }
  }
  
  Future<void> _exportTranscript(Note note) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      final outputPath = await exportService.exportTranscriptAsText(note);
      
      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('转写原文已保存到: $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e, title: '导出失败');
      }
    }
  }
  
  Future<void> _regenerate(VideoRecord video) async {
    setState(() => _isRegenerating = true);
    
    try {
      final processor = ref.read(videoProcessorProvider);
      await processor.retryProcessing(video: video);
      
      ref.invalidate(videoProvider(widget.videoId));
      ref.invalidate(noteProvider(widget.videoId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('笔记已重新生成')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorWithRetry(
          context,
          e,
          title: '重新生成失败',
          onRetry: () => _regenerate(video),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }
}
