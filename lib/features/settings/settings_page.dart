import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/features/settings/widgets/asr_settings.dart';
import 'package:keeji/features/settings/widgets/llm_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _OtherSettings extends ConsumerStatefulWidget {
  const _OtherSettings();

  @override
  ConsumerState<_OtherSettings> createState() => _OtherSettingsState();
}

class _OtherSettingsState extends ConsumerState<_OtherSettings> {
  bool _audioChunkEnabled = true;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioChunkEnabled = prefs.getBool('audio_chunk_enabled') ?? true;
      _isLoading = false;
    });
  }
  
  Future<void> _saveSettings(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_chunk_enabled', value);
    setState(() {
      _audioChunkEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        SwitchListTile(
          title: const Text('启用长音频分段'),
          subtitle: const Text('长音频自动在静音处切分后转写'),
          value: _audioChunkEnabled,
          onChanged: _saveSettings,
        ),
      ],
    );
  }
}
