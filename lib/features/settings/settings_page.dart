import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/features/settings/widgets/asr_settings.dart';
import 'package:keeji/features/settings/widgets/llm_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '语音转写 (ASR)',
            icon: Icons.mic,
            child: const AsrSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '笔记生成 (LLM)',
            icon: Icons.auto_awesome,
            child: const LlmSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '其他设置',
            icon: Icons.tune,
            child: const _OtherSettings(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _OtherSettings extends ConsumerWidget {
  const _OtherSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('启用长音频分段'),
          subtitle: const Text('长音频自动在静音处切分后转写'),
          value: true,
          onChanged: (value) {
            // TODO: 保存设置
          },
        ),
      ],
    );
  }
}
