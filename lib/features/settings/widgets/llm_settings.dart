import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/core/constants.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/l10n/app_localizations.dart';
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
    
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: InputDecoration(
            labelText: l10n.apiKey,
            hintText: l10n.apiKey,
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _baseUrlController,
          decoration: InputDecoration(
            labelText: l10n.apiBaseUrl,
            hintText: 'https://api.example.com/v1',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _modelController,
          decoration: InputDecoration(
            labelText: l10n.model,
            hintText: l10n.model,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text(l10n.saveSettings),
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
                label: Text(_isTesting ? l10n.testing : l10n.testConnection),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    final llmService = ref.read(llmServiceProvider);
    await llmService.updateConfig(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      model: _modelController.text,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSaved)),
      );
    }
  }
  
  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterApiKey)),
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
      
      final result = await llmService.testConnection(
        modelNotFoundMessage: l10n.modelNotFound(_modelController.text),
      );
      
      if (mounted) {
        if (result == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.connectionSuccess),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        } else {
          _showErrorDialog(result, l10n);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('${l10n.connectionFailed}: $e', l10n);
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }
  
  void _showErrorDialog(String message, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(ctx).colorScheme.error,
        ),
        title: Text(l10n.connectionFailed),
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
              l10n.currentConfig,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${l10n.apiBaseUrl}: ${_baseUrlController.text}'),
            Text('${l10n.model}: ${_modelController.text}'),
            const SizedBox(height: 12),
            Text(l10n.checkConfig),
            Text('• ${l10n.checkApiKey}'),
            Text('• ${l10n.checkApiUrl}'),
            Text('• ${l10n.checkNetwork}'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
