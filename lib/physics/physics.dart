import 'dart:math';
import '../models/game_object.dart';
import '../constants/app_constants.dart';

class Physics {
  static void updateObject(GameObject obj, double dt, double screenHeight) {
    obj.velocityY -= AppConstants.gravity * dt;
    obj.y += obj.velocityY * dt;
    obj.x += obj.velocityX * dt;
    obj.rotation += (obj.velocityX / 200) * dt * 3;

    if (obj.y > screenHeight * 0.9) {
      obj.velocityY = -(obj.velocityY.abs() * 0.5); 
    }
  }

  static void updateSlice(GameObject obj, double dt) {
    obj.sliceVelocityY -= AppConstants.gravity * dt;
    obj.y += obj.sliceVelocityY * dt;
    obj.x += obj.sliceVelocityX * dt;
    obj.rotation += dt * 5; 
  }

  static double getVelocityX(Random rng) {
    return (rng.nextDouble() - 0.5) * 350;
  }

  static double getVelocityY(Random rng, double speedMultiplier) {
    return (800 + rng.nextDouble() * 200) * speedMultiplier;
  }
}