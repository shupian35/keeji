import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final Player _player;
  late final VideoController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _initPlayer();
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
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildError(context);
    }
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _togglePlay,
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
        _buildControls(context),
      ],
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

  Widget _buildControls(BuildContext context) {
    return StreamBuilder(
      stream: _player.stream.playing,
      initialData: _player.state.playing,
      builder: (context, playingSnapshot) {
        return StreamBuilder<Duration>(
          stream: _player.stream.position,
          initialData: _player.state.position,
          builder: (context, positionSnapshot) {
            return StreamBuilder<Duration>(
              stream: _player.stream.duration,
              initialData: _player.state.duration,
              builder: (context, durationSnapshot) {
                return StreamBuilder<double>(
                  stream: _player.stream.volume,
                  initialData: _player.state.volume,
                  builder: (context, volumeSnapshot) {
                    final isPlaying = playingSnapshot.data ?? false;
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final volume = volumeSnapshot.data ?? 100.0;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.grey[900],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: duration.inMilliseconds > 0
                                ? position.inMilliseconds / duration.inMilliseconds
                                : 0,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlay,
                              ),
                              Expanded(
                                child: Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  volume > 0 ? Icons.volume_up : Icons.volume_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _toggleMute,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _togglePlay() {
    _player.playOrPause();
  }

  void _toggleMute() {
    final currentVol = _player.state.volume;
    _player.setVolume(currentVol > 0 ? 0.0 : 100.0);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
