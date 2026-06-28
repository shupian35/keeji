import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AsrPreset {
  final String name;
  final String baseUrl;
  final String model;
  
  const _AsrPreset({
    required this.name,
    required this.baseUrl,
    required this.model,
  });
}

const _asrPresets = [
  _AsrPreset(
    name: 'SiliconFlow',
    baseUrl: 'https://api.siliconflow.cn/v1',
    model: 'FunAudioLLM/SenseVoiceSmall',
  ),
  _AsrPreset(
    name: '小米 MiMo',
    baseUrl: 'https://api.xiaomimimo.com/v1',
    model: 'mimo-v2.5-asr',
  ),
  _AsrPreset(
    name: 'OpenAI Whisper',
    baseUrl: 'https://api.openai.com/v1',
    model: 'whisper-1',
  ),
  _AsrPreset(
    name: '自定义',
    baseUrl: '',
    model: '',
  ),
];

class AsrSettings extends ConsumerStatefulWidget {
  const AsrSettings({super.key});

  @override
  ConsumerState<AsrSettings> createState() => _AsrSettingsState();
}

class _AsrSettingsState extends ConsumerState<AsrSettings> {
  late TextEditingController _apiKeyController;
  late TextEditingController _baseUrlController;
  late TextEditingController _modelController;
  int _selectedPreset = 0;
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
    final baseUrl = prefs.getString('asr_base_url') ?? AppConstants.defaultAsrBaseUrl;
    final model = prefs.getString('asr_model') ?? AppConstants.defaultAsrModel;
    
    // 检测当前配置匹配哪个预设
    int presetIndex = _asrPresets.length - 1; // 默认自定义
    for (int i = 0; i < _asrPresets.length - 1; i++) {
      if (_asrPresets[i].baseUrl == baseUrl && _asrPresets[i].model == model) {
        presetIndex = i;
        break;
      }
    }
    
    setState(() {
      _apiKeyController.text = prefs.getString('asr_api_key') ?? '';
      _baseUrlController.text = baseUrl;
      _modelController.text = model;
      _selectedPreset = presetIndex;
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
  
  void _onPresetChanged(int? index) {
    if (index == null) return;
    setState(() {
      _selectedPreset = index;
      if (index < _asrPresets.length - 1) {
        _baseUrlController.text = _asrPresets[index].baseUrl;
        _modelController.text = _asrPresets[index].model;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _selectedPreset,
          decoration: const InputDecoration(
            labelText: '服务商预设',
            border: OutlineInputBorder(),
          ),
          items: _asrPresets.asMap().entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value.name),
            );
          }).toList(),
          onChanged: _onPresetChanged,
        ),
        const SizedBox(height: 12),
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
        if (_selectedPreset == 1) // 小米 MiMo
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '提示: 小米 MiMo ASR 使用 chat completions 接口，音频会自动转为 base64',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
  
  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入 API Key')),
      );
      return;
    }
    
    setState(() => _isTesting = true);
    
    try {
      final asrService = ref.read(asrServiceProvider);
      await asrService.updateConfig(
        apiKey: _apiKeyController.text,
        baseUrl: _baseUrlController.text,
        model: _modelController.text,
      );
      
      final result = await asrService.testConnection();
      
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
