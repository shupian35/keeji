import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AsrPreset {
  final String id;
  final String name;
  final String baseUrl;
  final String model;
  
  const _AsrPreset({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.model,
  });
}

const _asrPresets = [
  _AsrPreset(
    id: 'siliconflow',
    name: 'SiliconFlow',
    baseUrl: 'https://api.siliconflow.cn/v1',
    model: 'FunAudioLLM/SenseVoiceSmall',
  ),
  _AsrPreset(
    id: 'xiaomi',
    name: '小米 MiMo',
    baseUrl: 'https://api.xiaomimimo.com/v1',
    model: 'mimo-v2.5-asr',
  ),
  _AsrPreset(
    id: 'openai',
    name: 'OpenAI Whisper',
    baseUrl: 'https://api.openai.com/v1',
    model: 'whisper-1',
  ),
  _AsrPreset(
    id: 'custom',
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
    
    // 加载上次选择的预设
    final lastPresetId = prefs.getString('asr_preset_id') ?? 'siliconflow';
    int presetIndex = _asrPresets.length - 1;
    for (int i = 0; i < _asrPresets.length; i++) {
      if (_asrPresets[i].id == lastPresetId) {
        presetIndex = i;
        break;
      }
    }
    
    setState(() {
      _selectedPreset = presetIndex;
      _baseUrlController.text = prefs.getString('asr_base_url') ?? _asrPresets[presetIndex].baseUrl;
      _modelController.text = prefs.getString('asr_model') ?? _asrPresets[presetIndex].model;
      _apiKeyController.text = prefs.getString('asr_api_key') ?? '';
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
  
  Future<void> _onPresetChanged(int? index) async {
    if (index == null) return;
    
    // 保存当前预设的设置
    await _saveCurrentPresetSettings();
    
    setState(() {
      _selectedPreset = index;
    });
    
    // 加载新预设的设置
    await _loadPresetSettings(_asrPresets[index].id);
  }
  
  Future<void> _saveCurrentPresetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final presetId = _asrPresets[_selectedPreset].id;
    
    // 保存当前预设的 API Key
    await prefs.setString('asr_api_key_$presetId', _apiKeyController.text);
    await prefs.setString('asr_base_url_$presetId', _baseUrlController.text);
    await prefs.setString('asr_model_$presetId', _modelController.text);
  }
  
  Future<void> _loadPresetSettings(String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    final preset = _asrPresets.firstWhere((p) => p.id == presetId, orElse: () => _asrPresets.last);
    
    setState(() {
      _apiKeyController.text = prefs.getString('asr_api_key_$presetId') ?? '';
      _baseUrlController.text = prefs.getString('asr_base_url_$presetId') ?? preset.baseUrl;
      _modelController.text = prefs.getString('asr_model_$presetId') ?? preset.model;
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
        if (_selectedPreset == 1)
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
    final prefs = await SharedPreferences.getInstance();
    final presetId = _asrPresets[_selectedPreset].id;
    
    // 保存预设 ID
    await prefs.setString('asr_preset_id', presetId);
    
    // 保存当前预设的设置
    await prefs.setString('asr_api_key_$presetId', _apiKeyController.text);
    await prefs.setString('asr_base_url_$presetId', _baseUrlController.text);
    await prefs.setString('asr_model_$presetId', _modelController.text);
    
    // 同时保存为全局设置（兼容）
    await prefs.setString('asr_api_key', _apiKeyController.text);
    await prefs.setString('asr_base_url', _baseUrlController.text);
    await prefs.setString('asr_model', _modelController.text);
    
    // 更新服务
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
