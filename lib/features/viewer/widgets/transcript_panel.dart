import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:keeji/services/asr_service.dart';

class TranscriptPanel extends StatelessWidget {
  final String? transcriptJson;
  
  const TranscriptPanel({super.key, this.transcriptJson});

  @override
  Widget build(BuildContext context) {
    if (transcriptJson == null || transcriptJson!.isEmpty) {
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
    
    final segments = _parseTranscript(transcriptJson!);
    
    if (segments.isEmpty) {
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
            const Text('转写内容解析失败'),
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
              const Spacer(),
              Text(
                '${segments.length} 段',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: segments.length,
            itemBuilder: (context, index) {
              final segment = segments[index];
              return _TranscriptSegmentWidget(segment: segment);
            },
          ),
        ),
      ],
    );
  }
  
  List<TranscriptSegment> _parseTranscript(String json) {
    try {
      final List<dynamic> data = jsonDecode(json);
      return data.map((item) => TranscriptSegment.fromJson(item)).toList();
    } catch (e) {
      debugPrint('解析转写内容失败: $e');
      return [];
    }
  }
}

class _TranscriptSegmentWidget extends StatelessWidget {
  final TranscriptSegment segment;
  
  const _TranscriptSegmentWidget({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(segment.start),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            segment.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
