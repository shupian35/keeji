import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/features/home/home_page.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';

final videoListProvider = StateNotifierProvider<VideoListNotifier, AsyncValue<List<VideoRecord>>>((ref) {
  final db = ref.watch(databaseProvider);
  return VideoListNotifier(db);
});

class VideoListNotifier extends StateNotifier<AsyncValue<List<VideoRecord>>> {
  final dynamic _db;
  Timer? _timer;
  
  VideoListNotifier(this._db) : super(const AsyncValue.loading()) {
    _loadVideos();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _loadVideos());
  }
  
  Future<void> _loadVideos() async {
    try {
      final videos = await _db.getAllVideos();
      state = AsyncValue.data(videos);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<void> refresh() async {
    await _loadVideos();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final selectedIdsProvider = StateProvider<Set<String>>((ref) => {});

class VideoList extends ConsumerWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoListProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(selectedIdsProvider);
    
    // 当退出选择模式时清空选择
    ref.listen(selectionModeProvider, (prev, next) {
      if (prev == true && next == false) {
        ref.read(selectedIdsProvider.notifier).state = {};
      }
    });
    
    return videosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
      data: (videos) {
        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无视频',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '点击右上角 + 导入视频',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            if (isSelectionMode)
              _buildSelectionBar(context, ref, videos, selectedIds),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoCard(
                    video: video,
                    isSelectionMode: isSelectionMode,
                    isSelected: selectedIds.contains(video.id),
                    onRefresh: () => ref.read(videoListProvider.notifier).refresh(),
                    onToggleSelection: () {
                      final ids = Set<String>.from(ref.read(selectedIdsProvider));
                      if (ids.contains(video.id)) {
                        ids.remove(video.id);
                      } else {
                        ids.add(video.id);
                      }
                      ref.read(selectedIdsProvider.notifier).state = ids;
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSelectionBar(BuildContext context, WidgetRef ref, List<VideoRecord> videos, Set<String> selectedIds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(
            '已选择 ${selectedIds.length} 项',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              ref.read(selectedIdsProvider.notifier).state = videos.map((v) => v.id).toSet();
            },
            child: const Text('全选'),
          ),
          TextButton(
            onPressed: () {
              ref.read(selectedIdsProvider.notifier).state = {};
            },
            child: const Text('取消全选'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: selectedIds.isNotEmpty
                ? () => _batchDelete(context, ref, videos, selectedIds)
                : null,
            icon: const Icon(Icons.delete_outline),
            label: const Text('批量删除'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: selectedIds.isNotEmpty
                ? () => _batchExport(context, ref, videos, selectedIds)
                : null,
            icon: const Icon(Icons.archive),
            label: const Text('批量导出'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _batchExport(BuildContext context, WidgetRef ref, List<VideoRecord> videos, Set<String> selectedIds) async {
    // 显示导出选项对话框
    final exportType = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择导出内容'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'notes'),
            child: const ListTile(
              leading: Icon(Icons.note),
              title: Text('导出笔记'),
              subtitle: Text('导出 AI 生成的 Markdown 笔记'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'transcripts'),
            child: const ListTile(
              leading: Icon(Icons.transcribe),
              title: Text('导出转写原文'),
              subtitle: Text('导出语音转写的原始文本'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'both'),
            child: const ListTile(
              leading: Icon(Icons.select_all),
              title: Text('全部导出'),
              subtitle: Text('同时导出笔记和转写原文'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
    
    if (exportType == null) return;
    
    final selectedVideos = videos.where((v) => selectedIds.contains(v.id)).toList();
    final db = ref.read(databaseProvider);
    final notes = <Note>[];
    
    for (final video in selectedVideos) {
      final note = await db.getNoteByVideoId(video.id);
      if (note != null) {
        notes.add(note);
      }
    }
    
    if (notes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选中的视频没有笔记')),
        );
      }
      return;
    }
    
    try {
      final exportService = ref.read(exportServiceProvider);
      String? result;
      
      switch (exportType) {
        case 'notes':
          result = await exportService.batchExportNotes(notes, exportTranscripts: false);
          break;
        case 'transcripts':
          result = await exportService.batchExportNotes(notes, exportNotes: false, exportTranscripts: true);
          break;
        case 'both':
          result = await exportService.batchExportNotes(notes, exportNotes: true, exportTranscripts: true);
          break;
      }
      
      if (context.mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已导出 ${notes.length} 个文件到: $result')),
          );
          ref.read(selectionModeProvider.notifier).state = false;
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, e, title: '批量导出失败');
      }
    }
  }
  
  Future<void> _batchDelete(BuildContext context, WidgetRef ref, List<VideoRecord> videos, Set<String> selectedIds) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.warning_amber,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的 ${selectedIds.length} 个视频吗？相关的笔记也会被删除，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final db = ref.read(databaseProvider);
    int deletedCount = 0;
    
    for (final videoId in selectedIds) {
      try {
        final note = await db.getNoteByVideoId(videoId);
        if (note != null) {
          await db.deleteNote(note.id);
        }
        await db.deleteVideo(videoId);
        deletedCount++;
      } catch (e) {
        // 继续删除其他视频
      }
    }
    
    ref.read(selectedIdsProvider.notifier).state = {};
    ref.read(selectionModeProvider.notifier).state = false;
    ref.read(videoListProvider.notifier).refresh();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除 $deletedCount 个视频')),
      );
    }
  }
}

class VideoCard extends ConsumerWidget {
  final VideoRecord video;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onRefresh;
  final VoidCallback onToggleSelection;
  
  const VideoCard({
    super.key,
    required this.video,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onRefresh,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection(),
              )
            : _buildStatusIcon(context),
        title: Text(
          video.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(context),
        trailing: isSelectionMode
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, ref, value),
                itemBuilder: (context) => [
                  if (video.status == VideoStatus.done)
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('查看笔记'),
                    ),
                  if (video.status == VideoStatus.failed)
                    const PopupMenuItem(
                      value: 'retry',
                      child: Text('重试'),
                    ),
                  const PopupMenuItem(
                    value: 'relocate',
                    child: Text('更新路径'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除'),
                  ),
                ],
              ),
        onTap: isSelectionMode
            ? onToggleSelection
            : (video.status == VideoStatus.done ? () => _viewNote(context) : null),
      ),
    );
  }
  
  Widget _buildStatusIcon(BuildContext context) {
    switch (video.status) {
      case VideoStatus.pending:
        return const CircleAvatar(
          child: Icon(Icons.hourglass_empty),
        );
      case VideoStatus.processing:
        return SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: video.progress,
            strokeWidth: 3,
          ),
        );
      case VideoStatus.done:
        return CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case VideoStatus.failed:
        return CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }
  
  Widget? _buildSubtitle(BuildContext context) {
    switch (video.status) {
      case VideoStatus.pending:
        return const Text('等待处理');
      case VideoStatus.processing:
        return Text('处理中 ${(video.progress * 100).toInt()}%');
      case VideoStatus.done:
        return Text(
          '${video.createdAt.year}-${video.createdAt.month.toString().padLeft(2, '0')}-${video.createdAt.day.toString().padLeft(2, '0')}',
        );
      case VideoStatus.failed:
        return Text(
          video.error ?? '处理失败',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }
  
  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'view':
        _viewNote(context);
        break;
      case 'retry':
        _retryProcessing(context, ref);
        break;
      case 'relocate':
        _relocateVideo(context, ref);
        break;
      case 'delete':
        _deleteVideo(context, ref);
        break;
    }
  }
  
  void _viewNote(BuildContext context) {
    context.push('/viewer/${video.id}');
  }
  
  Future<void> _retryProcessing(BuildContext context, WidgetRef ref) async {
    try {
      final processor = ref.read(videoProcessorProvider);
      await processor.retryProcessing(video: video);
      onRefresh();
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorWithRetry(
          context,
          e,
          title: '重试失败',
          onRetry: () => _retryProcessing(context, ref),
        );
      }
    }
  }
  
  Future<void> _relocateVideo(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.videoExtensions
          .map((e) => e.replaceFirst('.', ''))
          .toList(),
    );
    
    if (result == null || result.files.isEmpty) return;
    
    final newPath = result.paths.first;
    if (newPath == null) return;
    
    try {
      final db = ref.read(databaseProvider);
      final updatedVideo = video.copyWith(filePath: newPath);
      await db.updateVideo(updatedVideo);
      onRefresh();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('路径已更新')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, e, title: '更新失败');
      }
    }
  }
  
  void _deleteVideo(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个视频吗？相关的笔记也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              
              final note = await db.getNoteByVideoId(video.id);
              if (note != null) {
                await db.deleteNote(note.id);
              }
              
              await db.deleteVideo(video.id);
              onRefresh();
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
