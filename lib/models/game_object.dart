import 'package:flutter/material.dart';

enum GameObjectType { face, bomb }
enum GameObjectState { flying, sliced, missed }

class GameObject {
  final String id;
  final GameObjectType type;

  final String? imagePath;
  final String? leftPath;
  final String? rightPath;
  final String? soundPath;
  final int score;

  double x;
  double y;
  double velocityX;
  double velocityY;

  // 🔥 ADD THESE (IMPORTANT)
  double sliceVelocityX;
  double sliceVelocityY;
  double rotation;

  GameObjectState state;
  double sliceOffsetX;
  double sliceOffsetY;

  final double size;

  GameObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    this.imagePath,
    this.leftPath,
    this.rightPath,
    this.soundPath,
    this.score = 0,
    this.state = GameObjectState.flying,
    this.sliceOffsetX = 0,
    this.sliceOffsetY = 0,
    this.size = 100,

    // 🔥 initialize here
    this.sliceVelocityX = 0,
    this.sliceVelocityY = 0,
    this.rotation = 0,
  });

  Offset get position => Offset(x, y);

  void update(double dt, double gravity) {
    if (state == GameObjectState.flying) {
      velocityY -= gravity * dt;
      x += velocityX * dt;
      y += velocityY * dt;
    } else if (state == GameObjectState.sliced) {
      sliceVelocityY -= gravity * dt;
      x += sliceVelocityX * dt;
      y += sliceVelocityY * dt;
      rotation += dt * 3;
    }
  }

  bool isOffScreen() => y < -size * 2 && velocityY < 0;
}