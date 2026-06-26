import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/models/video_record.dart';

final videoListFutureProvider = FutureProvider<List<VideoRecord>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllVideos();
});

class VideoList extends ConsumerWidget {
  const VideoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(videoListFutureProvider);
    
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
            return VideoCard(video: video);
          },
        );
      },
    );
  }
}

class VideoCard extends ConsumerWidget {
  final VideoRecord video;
  
  const VideoCard({super.key, required this.video});

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
            const PopupMenuItem(
              value: 'view',
              child: Text('查看笔记'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('删除'),
            ),
          ],
        ),
        onTap: () => _viewNote(context),
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
        return CircularProgressIndicator(
          value: video.progress,
          strokeWidth: 3,
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
        );
    }
  }
  
  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'view':
        _viewNote(context);
        break;
      case 'delete':
        _deleteVideo(context, ref);
        break;
    }
  }
  
  void _viewNote(BuildContext context) {
    // TODO: 跳转到笔记查看页面
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
              await db.deleteVideo(video.id);
              ref.invalidate(videoListFutureProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
