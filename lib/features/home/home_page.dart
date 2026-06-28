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
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              tooltip: '导入',
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
                const PopupMenuItem(
                  value: 'video',
                  child: ListTile(
                    leading: Icon(Icons.video_library),
                    title: Text('导入视频'),
                    subtitle: Text('从视频提取音频转写并生成笔记'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'text',
                  child: ListTile(
                    leading: Icon(Icons.text_snippet),
                    title: Text('导入原文'),
                    subtitle: Text('从文本文件直接生成笔记'),
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
