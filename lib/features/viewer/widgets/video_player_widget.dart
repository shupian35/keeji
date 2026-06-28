import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'video_controls.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Player? player;
  final VideoController? controller;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    this.player,
    this.controller,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _ownsPlayer = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.player != null && widget.controller != null) {
      _player = widget.player!;
      _controller = widget.controller!;
      _isInitialized = true;
    } else {
      _player = Player();
      _controller = VideoController(_player);
      _ownsPlayer = true;
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    try {
      await _player.open(Media(widget.videoPath));
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_ownsPlayer) {
      _player.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _player.playOrPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        final newPos = _player.state.position - const Duration(seconds: 5);
        _player.seek(newPos);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        final newPos = _player.state.position + const Duration(seconds: 5);
        _player.seek(newPos);
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        final currentVol = _player.state.volume;
        _player.setVolume(currentVol > 0 ? 0 : 100);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildError(context);
    }
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _player.playOrPause(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.black,
                    child: Center(
                      child: Video(
                        controller: _controller,
                        controls: NoVideoControls,
                      ),
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: _player.stream.playing,
                    initialData: _player.state.playing,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data ?? false;
                      if (!isPlaying) {
                        return Icon(
                          Icons.play_arrow_rounded,
                          size: 64,
                          color: Colors.white.withAlpha(180),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          VideoControls(player: _player),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('无法播放此视频', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
