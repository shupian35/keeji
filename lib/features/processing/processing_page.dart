import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/models/video_record.dart';

final videoStreamProvider = StreamProvider.family<VideoRecord?, String>((ref, videoId) {
  final db = ref.watch(databaseProvider);
  return db.watchVideoById(videoId);
});

class ProcessingPage extends ConsumerWidget {
  final String videoId;
  
  const ProcessingPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoAsync = ref.watch(videoStreamProvider(videoId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('处理中'),
      ),
      body: videoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('错误: $error')),
        data: (video) {
          if (video == null) {
            return const Center(child: Text('视频不存在'));
          }
          
          if (video.status == VideoStatus.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/viewer/${video.id}');
            });
          }
          
          if (video.status == VideoStatus.failed) {
            return _buildFailed(context, ref, video);
          }
          
          return _buildProcessing(context, video);
        },
      ),
    );
  }
  
  Widget _buildProcessing(BuildContext context, VideoRecord video) {
    final progress = video.progress;
    final stage = _getStage(progress);
    
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '正在处理视频...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildProgressSteps(context, progress),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                stage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFailed(BuildContext context, WidgetRef ref, VideoRecord video) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '处理失败',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                video.error ?? '未知错误',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('返回主页'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _retry(context, ref, video),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressSteps(BuildContext context, double progress) {
    final steps = [
      _Step('提取音频', Icons.audiotrack, progress >= 0.3),
      _Step('语音转写', Icons.mic, progress >= 0.7),
      _Step('生成笔记', Icons.auto_awesome, progress >= 1.0),
    ];
    
    return Column(
      children: steps.map((step) {
        return ListTile(
          leading: Icon(
            step.icon,
            color: step.completed
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            step.title,
            style: TextStyle(
              color: step.completed
                  ? null
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: step.completed
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        );
      }).toList(),
    );
  }
  
  String _getStage(double progress) {
    if (progress < 0.3) return '正在提取音频...';
    if (progress < 0.7) return '正在语音转写...';
    if (progress < 1.0) return '正在生成笔记...';
    return '处理完成';
  }
  
  Future<void> _retry(BuildContext context, WidgetRef ref, VideoRecord video) async {
    try {
      final processor = ref.read(videoProcessorProvider);
      await processor.retryProcessing(video: video);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorWithRetry(
          context,
          e,
          title: '重试失败',
          onRetry: () => _retry(context, ref, video),
        );
      }
    }
  }
}

class _Step {
  final String title;
  final IconData icon;
  final bool completed;
  
  const _Step(this.title, this.icon, this.completed);
}
