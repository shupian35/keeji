import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'volume_slider.dart';
import 'speed_selector.dart';

class VideoControls extends StatelessWidget {
  final Player player;

  const VideoControls({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.grey[900],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProgressBar(context),
          _buildControlsRow(context),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      initialData: player.state.position,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration>(
          stream: player.stream.duration,
          initialData: player.state.duration,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: Colors.white.withAlpha(32),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  player.seek(newPosition);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildControlsRow(BuildContext context) {
    return StreamBuilder<bool>(
      stream: player.stream.playing,
      initialData: player.state.playing,
      builder: (context, playingSnapshot) {
        return StreamBuilder<Duration>(
          stream: player.stream.position,
          initialData: player.state.position,
          builder: (context, positionSnapshot) {
            return StreamBuilder<Duration>(
              stream: player.stream.duration,
              initialData: player.state.duration,
              builder: (context, durationSnapshot) {
                return StreamBuilder<double>(
                  stream: player.stream.volume,
                  initialData: player.state.volume,
                  builder: (context, volumeSnapshot) {
                    return StreamBuilder<double>(
                      stream: player.stream.rate,
                      initialData: player.state.rate,
                      builder: (context, rateSnapshot) {
                        return StreamBuilder<bool>(
                          stream: player.stream.buffering,
                          initialData: player.state.buffering,
                          builder: (context, bufferingSnapshot) {
                            final isPlaying = playingSnapshot.data ?? false;
                            final position = positionSnapshot.data ?? Duration.zero;
                            final duration = durationSnapshot.data ?? Duration.zero;
                            final volume = volumeSnapshot.data ?? 100.0;
                            final rate = rateSnapshot.data ?? 1.0;
                            final isBuffering = bufferingSnapshot.data ?? false;

                            return Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => player.playOrPause(),
                                ),
                                if (isBuffering)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                SpeedSelector(
                                  currentSpeed: rate,
                                  onSpeedChanged: (speed) => player.setRate(speed),
                                ),
                                VolumeSlider(
                                  volume: volume,
                                  onVolumeChanged: (vol) => player.setVolume(vol),
                                ),
                              ],
                            );
                          },
                        );
                      },
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

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
