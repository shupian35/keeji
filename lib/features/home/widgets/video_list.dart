import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/models/video_record.dart';

final videoListProvider = StateNotifierProvider<VideoListNotifier, AsyncValue<List<VideoRecord>>>((ref) {
  final db = ref.watch(databaseProvider);
  return VideoListNotifier(db);
});

class VideoListNotifier extends StateNotifier<AsyncValue<List<VideoRecord>>> {
  final dynamic _db;
  Timer? _timer;
  
  VideoListNotifier(this._db) : super(const AsyncValue.loading()) {
    _loadVideos();
    // 每2秒刷新一次
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

// 兼容旧代码
final videoListFutureProvider = videoListProvider;

class VideoList extends ConsumerWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoListProvider);
    
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
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return VideoCard(
              video: video,
              onRefresh: () => ref.read(videoListProvider.notifier).refresh(),
            );
          },
        );
      },
    );
  }
}

class VideoCard extends ConsumerWidget {
  final VideoRecord video;
  final VoidCallback onRefresh;
  
  const VideoCard({
    super.key,
    required this.video,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildStatusIcon(context),
        title: Text(
          video.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(context),
        trailing: PopupMenuButton<String>(
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
        onTap: video.status == VideoStatus.done
            ? () => _viewNote(context)
            : null,
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
