import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keeji/features/home/widgets/video_list.dart';

final selectionModeProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = ref.watch(selectionModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode ? const Text('选择视频') : const Text('课记'),
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
              tooltip: '批量操作',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/import'),
              tooltip: '导入视频',
            ),
          ],
        ],
      ),
      body: const VideoList(),
    );
  }
}
