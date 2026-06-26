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
      // 尝试作为纯文本显示
      final plainText = _tryParseAsPlainText(transcriptJson!);
      if (plainText != null) {
        return _buildPlainTextPanel(context, plainText);
      }
      
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
            const SizedBox(height: 8),
            Text(
              '内容格式: ${transcriptJson!.substring(0, transcriptJson!.length.clamp(0, 50))}...',
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
  
  Widget _buildPlainTextPanel(BuildContext context, String text) {
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
            child: SelectableText(text),
          ),
        ),
      ],
    );
  }
  
  List<TranscriptSegment> _parseTranscript(String json) {
    try {
      debugPrint('转写内容原始数据: $json');
      final dynamic data = jsonDecode(json);
      debugPrint('解析后的数据类型: ${data.runtimeType}');
      
      // 如果是数组
      if (data is List) {
        debugPrint('数据是数组，长度: ${data.length}');
        if (data.isNotEmpty) {
          debugPrint('第一个元素: ${data[0]}');
          debugPrint('第一个元素类型: ${data[0].runtimeType}');
        }
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return TranscriptSegment.fromJson(item);
          }
          debugPrint('元素不是 Map: $item');
          return null;
        }).whereType<TranscriptSegment>().toList();
      }
      
      // 如果是对象，尝试提取 segments 字段
      if (data is Map<String, dynamic>) {
        debugPrint('数据是对象，键: ${data.keys.toList()}');
        if (data.containsKey('segments')) {
          final segments = data['segments'];
          if (segments is List) {
            return segments.map((item) {
              if (item is Map<String, dynamic>) {
                return TranscriptSegment.fromJson(item);
              }
              return null;
            }).whereType<TranscriptSegment>().toList();
          }
        }
      }
      
      return [];
    } catch (e) {
      debugPrint('解析转写内容失败: $e');
      return [];
    }
  }
  
  String? _tryParseAsPlainText(String json) {
    try {
      final dynamic data = jsonDecode(json);
      if (data is List && data.length == 1) {
        final item = data[0];
        if (item is Map<String, dynamic> && item.containsKey('text')) {
          return item['text'] as String;
        }
      }
      return null;
    } catch (_) {
      return null;
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
