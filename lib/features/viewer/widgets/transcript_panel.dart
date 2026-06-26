import 'package:flutter/material.dart';

class TranscriptPanel extends StatelessWidget {
  final String? transcriptText;
  
  const TranscriptPanel({super.key, this.transcriptText});

  @override
  Widget build(BuildContext context) {
    if (transcriptText == null || transcriptText!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.transcribe,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text('暂无转写内容'),
            const SizedBox(height: 8),
            Text(
              '视频处理完成后会显示转写原文',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.transcribe, size: 20),
              const SizedBox(width: 8),
              Text(
                '转写原文',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              transcriptText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
