import 'package:flutter/material.dart';

class ParticleEffect extends StatelessWidget {
  final Offset position;

  const ParticleEffect({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: const IgnorePointer(
        child: SizedBox(
          width: 10,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}