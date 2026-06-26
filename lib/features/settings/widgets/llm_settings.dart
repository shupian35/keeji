import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/constants.dart';

class LlmSettings extends ConsumerStatefulWidget {
  const LlmSettings({super.key});

  @override
  ConsumerState<LlmSettings> createState() => _LlmSettingsState();
}

class _LlmSettingsState extends ConsumerState<LlmSettings> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  
  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController(text: AppConstants.defaultLlmBaseUrl);
    _modelController = TextEditingController(text: AppConstants.defaultLlmModel);
    // TODO: 从 SharedPreferences 加载保存的设置
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: '输入 LLM API Key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _baseUrlController,
          decoration: const InputDecoration(
            labelText: 'API 地址',
            hintText: 'https://api.example.com/v1',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _modelController,
          decoration: const InputDecoration(
            labelText: '模型',
            hintText: '输入模型名称',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('保存 LLM 设置'),
          ),
        ),
      ],
    );
  }
  
  void _saveSettings() {
    // TODO: 保存到 SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LLM 设置已保存')),
    );
  }
}
