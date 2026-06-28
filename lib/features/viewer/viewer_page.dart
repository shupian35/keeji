import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:keeji/core/providers.dart';
import 'package:keeji/core/error_handler.dart';
import 'package:keeji/l10n/app_localizations.dart';
import 'package:keeji/models/video_record.dart';
import 'package:keeji/models/note.dart';
import 'package:keeji/features/viewer/widgets/video_player_widget.dart';
import 'package:keeji/features/viewer/widgets/transcript_panel.dart';

final videoProvider = FutureProvider.family<VideoRecord?, String>((ref, videoId) async {
  final db = ref.watch(databaseProvider);
  return db.getVideoById(videoId);
});

final noteProvider = FutureProvider.family<Note?, String>((ref, videoId) async {
  final db = ref.watch(databaseProvider);
  return db.getNoteByVideoId(videoId);
});

class ViewerPage extends ConsumerStatefulWidget {
  final String videoId;
  
  const ViewerPage({super.key, required this.videoId});

  @override
  ConsumerState<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends ConsumerState<ViewerPage> {
  bool _showTranscript = false;
  bool _isRegenerating = false;
  Player? _player;
  VideoController? _controller;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayerIfNeeded();
    });
  }
  
  void _initPlayerIfNeeded() {
    final videoAsync = ref.read(videoProvider(widget.videoId));
    videoAsync.whenData((video) {
      if (video != null && video.sourceType == SourceType.video && mounted) {
        setState(() {
          _player = Player();
          _controller = VideoController(_player!);
        });
        _player!.open(Media(video.filePath));
      }
    });
  }
  
  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoProvider(widget.videoId));
    final noteAsync = ref.watch(noteProvider(widget.videoId));
    final l10n = AppLocalizations.of(context)!;
    
    return videoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.error)),
        body: Center(child: Text('${l10n.error}: $error')),
      ),
      data: (video) {
        if (video == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.error)),
            body: Center(child: Text(l10n.error)),
          );
        }
        
        return noteAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(video.filename)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: Text(video.filename)),
            body: Center(child: Text('${l10n.error}: $error')),
          ),
          data: (note) {
            return _buildContent(video, note, l10n);
          },
        );
      },
    );
  }
  
  Widget _buildContent(VideoRecord video, Note? note, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note?.title ?? video.filename),
        actions: [
          if (note != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyNote(note, l10n),
              tooltip: l10n.copyNote,
            ),
          IconButton(
            icon: Icon(_showTranscript ? Icons.description : Icons.description_outlined),
            onPressed: () => setState(() => _showTranscript = !_showTranscript),
            tooltip: l10n.transcriptOriginal,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value, video, note, l10n),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export_md',
                child: Text(l10n.exportNote),
              ),
              PopupMenuItem(
                value: 'export_txt',
                child: Text(l10n.exportTranscript),
              ),
              PopupMenuItem(
                value: 'regenerate',
                child: Text(l10n.regenerate),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          if (video.sourceType == SourceType.video) ...[
            SizedBox(
              width: 400,
              child: Stack(
                children: [
                  VideoPlayerWidget(
                    videoPath: video.filePath,
                    player: _player,
                    controller: _controller,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.white),
                      onPressed: () => _enterFullscreen(video.filePath),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
          ],
          Expanded(
            child: note != null
                ? _MarkdownViewer(content: note.contentMd)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.noNote),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _isRegenerating ? null : () => _regenerate(video, l10n),
                          icon: _isRegenerating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isRegenerating ? l10n.generating : l10n.generateNote),
                        ),
                      ],
                    ),
                  ),
          ),
          if (_showTranscript) ...[
            const VerticalDivider(width: 1),
            Container(
              width: 300,
              constraints: const BoxConstraints(minHeight: 200),
              child: TranscriptPanel(
                transcriptText: note?.transcriptJson,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _handleAction(String action, VideoRecord video, Note? note, AppLocalizations l10n) async {
    switch (action) {
      case 'export_md':
        if (note != null) {
          await _exportMarkdown(note, video.filename, l10n);
        }
        break;
      case 'export_txt':
        if (note != null) {
          await _exportTranscript(note, video.filename, l10n);
        }
        break;
      case 'regenerate':
        await _regenerate(video, l10n);
        break;
    }
  }
  
  void _copyNote(Note note, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: note.contentMd));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noteCopied)),
      );
    }
  }
  
  Future<void> _exportMarkdown(Note note, String videoFilename, AppLocalizations l10n) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      final outputPath = await exportService.exportNoteAsMarkdown(note, sourceFileName: videoFilename);
      
      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportNote}: $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e, title: l10n.exportFailed);
      }
    }
  }
  
  Future<void> _exportTranscript(Note note, String videoFilename, AppLocalizations l10n) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      final outputPath = await exportService.exportTranscriptAsText(note, sourceFileName: videoFilename);
      
      if (outputPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.exportTranscript}: $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e, title: l10n.exportFailed);
      }
    }
  }
  
  Future<void> _regenerate(VideoRecord video, AppLocalizations l10n) async {
    setState(() => _isRegenerating = true);
    
    try {
      final processor = ref.read(videoProcessorProvider);
      await processor.retryProcessing(video: video);
      
      ref.invalidate(videoProvider(widget.videoId));
      ref.invalidate(noteProvider(widget.videoId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noteRegenerated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorWithRetry(
          context,
          e,
          title: l10n.regenerateFailed,
          onRetry: () => _regenerate(video, l10n),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
    }
  }
  
  void _enterFullscreen(String videoPath) {
    if (_player == null || _controller == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenVideoPage(
          videoPath: videoPath,
          player: _player!,
          controller: _controller!,
        ),
      ),
    );
  }
}

class _FullscreenVideoPage extends StatelessWidget {
  final String videoPath;
  final Player player;
  final VideoController controller;

  const _FullscreenVideoPage({
    required this.videoPath,
    required this.player,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VideoPlayerWidget(
              videoPath: videoPath,
              player: player,
              controller: controller,
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownViewer extends StatelessWidget {
  final String content;
  
  const _MarkdownViewer({required this.content});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ExcludeSemantics(
      child: SelectionArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MarkdownBody(
            data: content,
            selectable: false,
            styleSheet: MarkdownStyleSheet(
              code: TextStyle(
                backgroundColor: isDark 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              codeblockDecoration: BoxDecoration(
                color: isDark 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              codeblockPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }
}
