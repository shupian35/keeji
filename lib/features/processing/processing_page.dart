import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.processing(0)),
      ),
      body: videoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('${l10n.error}: $error')),
        data: (video) {
          if (video == null) {
            return Center(child: Text(l10n.error));
          }
          
          if (video.status == VideoStatus.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/viewer/${video.id}');
            });
          }
          
          if (video.status == VideoStatus.failed) {
            return _buildFailed(context, ref, video, l10n);
          }
          
          return _buildProcessing(context, video, l10n);
        },
      ),
    );
  }
  
  Widget _buildProcessing(BuildContext context, VideoRecord video, AppLocalizations l10n) {
    final progress = video.progress;
    final stage = _getStage(progress, l10n);
    
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
                l10n.processing((progress * 100).toInt()),
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
              _buildProgressSteps(context, progress, l10n),
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
  
  Widget _buildFailed(BuildContext context, WidgetRef ref, VideoRecord video, AppLocalizations l10n) {
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
                l10n.failed,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                video.error ?? l10n.error,
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
                    child: Text(l10n.home),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _retry(context, ref, video, l10n),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressSteps(BuildContext context, double progress, AppLocalizations l10n) {
    final steps = [
      _Step(l10n.asrSettings, Icons.audiotrack, progress >= 0.3),
      _Step(l10n.asrSettings, Icons.mic, progress >= 0.7),
      _Step(l10n.llmSettings, Icons.auto_awesome, progress >= 1.0),
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
  
  String _getStage(double progress, AppLocalizations l10n) {
    if (progress < 0.3) return l10n.asrSettings;
    if (progress < 0.7) return l10n.asrSettings;
    if (progress < 1.0) return l10n.llmSettings;
    return l10n.done;
  }
  
  Future<void> _retry(BuildContext context, WidgetRef ref, VideoRecord video, AppLocalizations l10n) async {
    try {
      final processor = ref.read(videoProcessorProvider);
      await processor.retryProcessing(video: video);
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showErrorWithRetry(
          context,
          e,
          title: l10n.retryFailed,
          onRetry: () => _retry(context, ref, video, l10n),
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
