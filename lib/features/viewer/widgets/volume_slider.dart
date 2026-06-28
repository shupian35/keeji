import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onVolumeChanged;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            volume > 0 ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => onVolumeChanged(volume > 0 ? 0 : 100),
        ),
        SizedBox(
          width: 100,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withAlpha(32),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: volume,
              min: 0,
              max: 100,
              onChanged: onVolumeChanged,
            ),
          ),
        ),
      ],
    );
  }
}
