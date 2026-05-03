import 'package:flutter/material.dart';
import '../models/game_object.dart';

class SliceableFace extends StatelessWidget {
  final GameObject object;
  final Size screenSize;

  const SliceableFace({
    super.key,
    required this.object,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final obj = object;
    final sh = screenSize.height;

    final screenX = obj.x - obj.size / 2;
    final screenY = sh - obj.y - obj.size / 2;

    // 🟢 FLYING
    if (obj.state == GameObjectState.flying) {
      return Positioned(
        left: screenX,
        top: screenY,
        child: SizedBox(
          width: obj.size,
          height: obj.size,
          child: Image.asset(
            obj.imagePath ?? '',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.low,
          ),
        ),
      );
    }

    // 🔥 SLICED (REAL CUT + SLASH)
    if (obj.state == GameObjectState.sliced) {
      return Stack(
        children: [
          // 🟢 LEFT PART
          if (obj.leftPath != null)
            Positioned(
              left: screenX - 15,
              top: screenY,
              child: Transform.rotate(
                angle: obj.rotation,
                child: Image.asset(
                  obj.leftPath!,
                  width: obj.size / 2,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),

          // 🟢 RIGHT PART
          if (obj.rightPath != null)
            Positioned(
              left: screenX + obj.size / 2 + 15,
              top: screenY,
              child: Transform.rotate(
                angle: -obj.rotation,
                child: Image.asset(
                  obj.rightPath!,
                  width: obj.size / 2,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),

          // 🔥 CLEAN SLASH (NO DOTS)
          Positioned(
            left: obj.sliceOffsetX - 50,
            top: obj.sliceOffsetY - 4,
            child: Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 100,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.orangeAccent,
                      Colors.white,
                      Colors.orangeAccent,
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}