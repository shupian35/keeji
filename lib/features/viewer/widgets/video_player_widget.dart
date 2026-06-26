import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String videoPath;
  
  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '视频播放器',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    videoPath.split('\\').last,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildControls(),
      ],
    );
  }
  
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () {},
          ),
          Expanded(
            child: Slider(
              value: 0,
              onChanged: (value) {},
            ),
          ),
          const Text(
            '00:00 / 00:00',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
