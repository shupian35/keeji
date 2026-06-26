import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LlmSettings extends ConsumerStatefulWidget {
  const LlmSettings({super.key});

  @override
  ConsumerState<LlmSettings> createState() => _LlmSettingsState();
}

class _LlmSettingsState extends ConsumerState<LlmSettings> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  bool _isLoading = true;
  bool _isTesting = false;
  
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
      _apiKeyController.text = prefs.getString('llm_api_key') ?? '';
      _baseUrlController.text = prefs.getString('llm_base_url') ?? AppConstants.defaultLlmBaseUrl;
      _modelController.text = prefs.getString('llm_model') ?? AppConstants.defaultLlmModel;
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
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('保存设置'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: Text(_isTesting ? '测试中...' : '测试连接'),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _saveSettings() async {
    final llmService = ref.read(llmServiceProvider);
    await llmService.updateConfig(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      model: _modelController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LLM 设置已保存')),
      );
    }
  }
  
  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API Key')),
      );
      return;
    }
    
    setState(() => _isTesting = true);
    
    try {
      final llmService = ref.read(llmServiceProvider);
      await llmService.updateConfig(
        apiKey: _apiKeyController.text,
        baseUrl: _baseUrlController.text,
        model: _modelController.text,
      );
      
      final result = await llmService.testConnection();
      
      if (mounted) {
        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('连接成功'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        } else {
          _showErrorDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('连接失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: const Text('连接测试失败'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              '当前配置：',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('API 地址: ${_baseUrlController.text}'),
            Text('模型: ${_modelController.text}'),
            const SizedBox(height: 12),
            const Text('请检查：'),
            const Text('• API Key 是否正确'),
            const Text('• API 地址格式是否正确'),
            const Text('• 网络连接是否正常'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
