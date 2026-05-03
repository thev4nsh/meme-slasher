import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static const _channel = MethodChannel('com.example.ninja_game/audio');
  
  // Only keep ONE player for BGM. Delete the SFX players!
  final AudioPlayer _bgPlayer = AudioPlayer();
  
  Future<void> _init() async {
    await _bgPlayer.setPlayerMode(PlayerMode.mediaPlayer);
  }

  Future<void> playBgMusic({double volume = 0.3}) async {
    await _init();
    await _channel.invokeMethod('requestBgmFocus'); // Pauses Spotify
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/bg.mp3'), volume: volume);
  }

  Future<void> stopBgMusic() async {
    await _bgPlayer.stop();
    await _bgPlayer.setReleaseMode(ReleaseMode.stop);
    await _channel.invokeMethod('abandonFocus'); // Resumes Spotify
  }

  Future<void> setLiveBgVolume(double v) async {
    await _init();
    await _bgPlayer.setVolume(v);
  }

  // 🔥 SFX now goes directly to Native Android (Zero Spotify interference)
  Future<void> playSound(String assetPath, {double volume = 1.0}) async {
    try {
      final path = "flutter_assets/$assetPath";
      await _channel.invokeMethod('playSfxNative', {
        'path': path,
        'volume': volume,
      });
    } catch (e) {
      print("Native SFX failed: $e");
    }
  }

  Future<void> stopAllSfx() async {
    // Native short sounds auto-destroy when finished, so this is just a safety placeholder
  }

  void dispose() {
    _bgPlayer.dispose();
  }
}