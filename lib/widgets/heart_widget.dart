import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class HeartWidget extends StatelessWidget {
  final int lives;
  const HeartWidget({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(AppConstants.maxLives, (i) {
        final filled = i < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedScale(
            scale: filled ? 1.0 : 0.75,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.favorite,
              color: filled
                  ? const Color(0xFFFF2D7A)
                  : Colors.white12,
              size: 28,
              shadows: filled
                  ? const [Shadow(color: Color(0xFFFF2D7A), blurRadius: 10)]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
