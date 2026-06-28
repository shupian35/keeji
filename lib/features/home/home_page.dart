import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keeji/features/home/widgets/video_list.dart';
import 'package:keeji/l10n/app_localizations.dart';

final selectionModeProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = ref.watch(selectionModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode ? const Text('选择视频') : Text(l10n.appName),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectionModeProvider.notifier).state = false;
                },
              )
            : null,
        actions: [
          if (!isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                ref.read(selectionModeProvider.notifier).state = true;
              },
              tooltip: l10n.batchExport,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              tooltip: l10n.import,
              onSelected: (value) {
                switch (value) {
                  case 'video':
                    context.push('/import');
                    break;
                  case 'text':
                    context.push('/import?type=text');
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'video',
                  child: ListTile(
                    leading: const Icon(Icons.video_library),
                    title: Text(l10n.importVideo),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'text',
                  child: ListTile(
                    leading: const Icon(Icons.text_snippet),
                    title: Text(l10n.importText),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: const VideoList(),
    );
  }
}
