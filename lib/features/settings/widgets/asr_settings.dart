import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsrSettings extends ConsumerStatefulWidget {
  const AsrSettings({super.key});

  @override
  ConsumerState<AsrSettings> createState() => _AsrSettingsState();
}

class _AsrSettingsState extends ConsumerState<AsrSettings> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _baseUrlController = TextEditingController();
    _modelController = TextEditingController();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('asr_api_key') ?? '';
      _baseUrlController.text = prefs.getString('asr_base_url') ?? AppConstants.defaultAsrBaseUrl;
      _modelController.text = prefs.getString('asr_model') ?? AppConstants.defaultAsrModel;
      _isLoading = false;
    });
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            hintText: '输入 ASR API Key',
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
            child: const Text('保存 ASR 设置'),
          ),
        ),
      ],
    );
  }
  
  Future<void> _saveSettings() async {
    final asrService = ref.read(asrServiceProvider);
    await asrService.updateConfig(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      model: _modelController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ASR 设置已保存')),
      );
    }
  }
}
