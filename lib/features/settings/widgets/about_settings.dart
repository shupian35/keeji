import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:keeji/l10n/app_localizations.dart';

class AboutSettings extends StatefulWidget {
  const AboutSettings({super.key});

  @override
  State<AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends State<AboutSettings> {
  String _version = '';
  List<String> _errorLogs = [];

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadErrorLogs();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _loadErrorLogs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _errorLogs = prefs.getStringList('error_logs') ?? [];
    });
  }

  Future<void> _clearErrorLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('error_logs');
    setState(() {
      _errorLogs = [];
    });
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorLogsCleared)),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.version),
          trailing: Text(_version),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: Text(l10n.projectHomepage),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('https://github.com/shupian35/keeji'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: Text(l10n.openSourceLicenses),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: '课记',
              applicationVersion: _version,
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: Text(l10n.errorLogs),
          trailing: Text('${_errorLogs.length}'),
          onTap: () => _showErrorLogs(context),
        ),
      ],
    );
  }

  void _showErrorLogs(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.errorLogs),
        content: SizedBox(
          width: 500,
          height: 400,
          child: _errorLogs.isEmpty
              ? Center(child: Text(l10n.noErrorLogs))
              : ListView.builder(
                  itemCount: _errorLogs.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _errorLogs[index],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (_errorLogs.isNotEmpty)
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _errorLogs.join('\n\n')));
                Navigator.pop(ctx);
              },
              child: Text(l10n.copyNote),
            ),
          if (_errorLogs.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _clearErrorLogs();
              },
              child: Text(l10n.clearErrorLogs),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class ErrorLogger {
  static Future<void> logError(dynamic error, {String? stackTrace}) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList('error_logs') ?? [];
    
    final timestamp = DateTime.now().toString();
    final logEntry = '[$timestamp]\n$error${stackTrace != null ? '\n\n$stackTrace' : ''}';
    
    logs.insert(0, logEntry);
    
    // Keep only last 50 logs
    if (logs.length > 50) {
      logs.removeRange(50, logs.length);
    }
    
    await prefs.setStringList('error_logs', logs);
  }
}
