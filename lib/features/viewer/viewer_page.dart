import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';
import 'package:keeji/features/viewer/widgets/video_player_widget.dart';
import 'package:keeji/features/viewer/widgets/transcript_panel.dart';

class ViewerPage extends ConsumerStatefulWidget {
  final String videoId;
  
  const ViewerPage({super.key, required this.videoId});

  @override
  ConsumerState<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends ConsumerState<ViewerPage> {
  bool _showTranscript = false;
  
  @override
  Widget build(BuildContext context) {
    // TODO: 从数据库获取视频和笔记
    final video = VideoRecord(
      id: widget.videoId,
      filename: '示例视频.mp4',
      filePath: '/path/to/video.mp4',
      status: VideoStatus.done,
      createdAt: DateTime.now(),
    );
    
    final note = Note(
      id: 'note-1',
      videoId: widget.videoId,
      title: '示例笔记',
      contentMd: '# 示例笔记\n\n这是一份示例笔记内容。',
      createdAt: DateTime.now(),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: Icon(_showTranscript ? Icons.description : Icons.description_outlined),
            onPressed: () => setState(() => _showTranscript = !_showTranscript),
            tooltip: '显示转写原文',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_md',
                child: Text('导出笔记'),
              ),
              const PopupMenuItem(
                value: 'export_txt',
                child: Text('导出转写'),
              ),
              const PopupMenuItem(
                value: 'regenerate',
                child: Text('重新生成'),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // 左侧：视频播放器
          SizedBox(
            width: 400,
            child: VideoPlayerWidget(videoPath: video.filePath),
          ),
          const VerticalDivider(width: 1),
          // 中间：笔记内容
          Expanded(
            child: Markdown(
              data: note.contentMd,
              padding: const EdgeInsets.all(16),
            ),
          ),
          // 右侧：转写原文面板
          if (_showTranscript) ...[
            const VerticalDivider(width: 1),
            SizedBox(
              width: 300,
              child: TranscriptPanel(
                transcriptJson: note.transcriptJson,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _handleAction(String action) {
    switch (action) {
      case 'export_md':
        // TODO: 导出笔记
        break;
      case 'export_txt':
        // TODO: 导出转写
        break;
      case 'regenerate':
        // TODO: 重新生成
        break;
    }
  }
}
