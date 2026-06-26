import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProcessingPage extends ConsumerStatefulWidget {
  final String videoId;
  
  const ProcessingPage({super.key, required this.videoId});

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends ConsumerState<ProcessingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('处理中'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(strokeWidth: 6),
                ),
                const SizedBox(height: 24),
                Text(
                  '正在处理视频...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildProgressSteps(),
                const SizedBox(height: 24),
                SizedBox(
                  width: 300,
                  child: LinearProgressIndicator(
                    value: 0.5, // TODO: 从状态获取实际进度
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '请稍候，处理完成后会自动跳转',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressSteps() {
    final steps = [
      _Step('提取音频', Icons.audiotrack, true),
      _Step('语音转写', Icons.mic, false),
      _Step('生成笔记', Icons.auto_awesome, false),
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
}

class _Step {
  final String title;
  final IconData icon;
  final bool completed;
  
  const _Step(this.title, this.icon, this.completed);
}
