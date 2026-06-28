import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keeji/app.dart';
import 'package:keeji/core/theme_provider.dart';
import 'package:keeji/features/settings/widgets/asr_settings.dart';
import 'package:keeji/features/settings/widgets/llm_settings.dart';
import 'package:keeji/features/settings/widgets/about_settings.dart';
import 'package:keeji/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: l10n.appearance,
            icon: Icons.palette,
            child: const _ThemeSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.settings,
            icon: Icons.language,
            child: const _LanguageSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.asrSettings,
            icon: Icons.mic,
            child: const AsrSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.llmSettings,
            icon: Icons.auto_awesome,
            child: const LlmSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.otherSettings,
            icon: Icons.tune,
            child: const _OtherSettings(),
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: l10n.about,
            icon: Icons.info_outline,
            child: const AboutSettings(),
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

class _ThemeSettings extends ConsumerWidget {
  const _ThemeSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildThemeOption(
          context,
          ref,
          title: l10n.followSystem,
          icon: Icons.brightness_auto,
          mode: ThemeMode.system,
          isSelected: themeMode == ThemeMode.system,
        ),
        _buildThemeOption(
          context,
          ref,
          title: l10n.lightMode,
          icon: Icons.light_mode,
          mode: ThemeMode.light,
          isSelected: themeMode == ThemeMode.light,
        ),
        _buildThemeOption(
          context,
          ref,
          title: l10n.darkMode,
          icon: Icons.dark_mode,
          mode: ThemeMode.dark,
          isSelected: themeMode == ThemeMode.dark,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : Icon(
              Icons.circle_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
    );
  }
}

class _LanguageSettings extends ConsumerWidget {
  const _LanguageSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    final currentLanguageCode = locale?.languageCode ?? 'zh';
    final currentCountryCode = locale?.countryCode;

    String currentLanguage;
    if (currentLanguageCode == 'zh' && currentCountryCode == 'TW') {
      currentLanguage = '繁體中文';
    } else if (currentLanguageCode == 'en') {
      currentLanguage = 'English';
    } else {
      currentLanguage = '简体中文';
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(currentLanguage),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () => _showLanguageDialog(context, ref),
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择语言 / Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              ctx,
              ref,
              title: '简体中文',
              locale: const Locale('zh'),
            ),
            _buildLanguageOption(
              ctx,
              ref,
              title: '繁體中文',
              locale: const Locale('zh', 'TW'),
            ),
            _buildLanguageOption(
              ctx,
              ref,
              title: 'English',
              locale: const Locale('en'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Locale locale,
  }) {
    final currentLocale = ref.watch(localeProvider);
    final isSelected = currentLocale?.languageCode == locale.languageCode &&
        currentLocale?.countryCode == locale.countryCode;

    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
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

    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SwitchListTile(
          title: Text(l10n.enableAudioChunking),
          subtitle: Text(l10n.enableAudioChunkingHint),
          value: _audioChunkEnabled,
          onChanged: _saveSettings,
        ),
      ],
    );
  }
}
