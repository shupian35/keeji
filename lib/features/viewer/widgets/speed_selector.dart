import 'package:flutter/material.dart';

class SpeedSelector extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  static const List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      icon: Text(
        '${currentSpeed}x',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      onSelected: onSpeedChanged,
      itemBuilder: (context) => speeds.map((speed) {
        return PopupMenuItem(
          value: speed,
          child: Row(
            children: [
              if (speed == currentSpeed)
                Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text('${speed}x'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
