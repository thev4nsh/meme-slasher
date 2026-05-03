import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../models/game_object.dart';
import '../services/sound_manager.dart';
import '../leaderboard/leaderboard_service.dart';
import '../physics/physics.dart';
import '../profile/user_service.dart';

enum GameState { idle, playing, paused, gameOver }

class GameProvider extends ChangeNotifier {
  final SoundManager _sound = SoundManager();
  final Random _rng = Random();
  GameState _gameState = GameState.idle;
  int _score = 0;
  int _lives = AppConstants.maxLives;
  int _highScore = 0;

  bool _sfxOn = true;
  bool _bgMusicOn = false;

  final List<GameObject> objects = [];

  Timer? _gameLoop;
  Timer? _spawnTimer;
  Timer? _comboTimer;
  DateTime? _lastFrame;
  int _idCounter = 0;

  Size _screenSize = const Size(400, 800);

  int _combo = 0;
  int lastBonus = 0;
  int _level = 1;

  double _timeScale = 1.0;
  bool _isSlowMotion = false;

  double _sfxVolume = 1.0;
  double _bgVolume = 0.4;
  bool _isGameOverTriggered = false;

  GameState get gameState => _gameState;
  int get score => _score;
  int get lives => _lives;
  int get highScore => _highScore;
  int get combo => _combo;
  int get level => _level;
  bool get sfxOn => _sfxOn;
  bool get bgMusicOn => _bgMusicOn;
  double get sfxVolume => _sfxVolume;
  double get bgVolume => _bgVolume;

  void setScreenSize(Size s) => _screenSize = s;

  // 🔥 ADDED: Play on app open
  void playWelcomeSound() {
    if (_sfxOn) _sound.playSound(kWelcomeSound, volume: _sfxVolume);
  }

  void toggleSfx() {
    _sfxOn = !_sfxOn;
    if (!_sfxOn) _sound.stopAllSfx();
    notifyListeners();
  }

  void toggleBgMusic() {
    _bgMusicOn = !_bgMusicOn;
    if (_bgMusicOn) {
      _sound.playBgMusic(volume: _bgVolume);
    } else {
      _sound.stopBgMusic();
    }
    notifyListeners();
  }

  void setSfxVolume(double v) {
    _sfxVolume = v;
    notifyListeners();
  }

  void setBgVolume(double v) {
    _bgVolume = v;
    _sound.setLiveBgVolume(v);
    notifyListeners();
  }

  void startGame() async {
    _score = 0;
    _lives = AppConstants.maxLives;
    _combo = 0;
    _level = 1;
    _isGameOverTriggered = false;
    _gameState = GameState.playing;
    objects.clear();
    _lastFrame = null;
    
    _highScore = await UserService.instance.getHighScore();

    if (_bgMusicOn) _sound.playBgMusic(volume: _bgVolume);
    _startLoops();
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState != GameState.playing) return;
    _gameState = GameState.paused;
    _stopLoops();
    _sound.stopAllSfx();
    notifyListeners();
  }

  void resumeGame() {
    if (_gameState != GameState.paused) return;
    _gameState = GameState.playing;
    _startLoops();
    notifyListeners();
  }

  void restartGame() => startGame();

  void exitToHome() {
    _stopLoops();
    _comboTimer?.cancel();
    _sound.stopBgMusic();
    _sound.stopAllSfx();
    _gameState = GameState.idle;
    objects.clear();
    notifyListeners();
  }

  void _increaseCombo() {
    _combo++;
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 900), () {
      _combo = 0;
      notifyListeners();
    });
  }

  int _getComboBonus() {
    if (_combo >= 5) return 8;
    if (_combo == 4) return 5;
    if (_combo == 3) return 4;
    return 0;
  }

  void _updateLevel() {
    _level = (_score ~/ 20) + 1;
    _level = _level.clamp(1, 15);
  }

  double _speedMultiplier() => 1 + (_level * 0.1);
  double _spawnDelayMultiplier() => max(0.5, 1 - (_level * 0.05));

  void _triggerSlowMotion() {
    if (_isSlowMotion) return;
    _isSlowMotion = true;
    _timeScale = 0.5;
    Future.delayed(const Duration(milliseconds: 200), () {
      _timeScale = 0.7;
      Future.delayed(const Duration(milliseconds: 150), () {
        _timeScale = 1.0;
        _isSlowMotion = false;
      });
    });
  }

  // 🔥 FIXED: Removed gameover sound from here
  Future<void> _triggerGameOver() async {
    if (_isGameOverTriggered) return;
    _isGameOverTriggered = true;
    _gameState = GameState.gameOver;
    _stopLoops();
    _comboTimer?.cancel();
    _sound.stopBgMusic();
    objects.clear();
    
    HapticFeedback.heavyImpact();
    try {
      final leaderboard = LeaderboardService();
      await leaderboard.submitScore(_score);
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> onSlice(String id, double touchX, double touchY, Size screenSize) async {
    if (_combo >= 3) _triggerSlowMotion();
    final index = objects.indexWhere((o) => o.id == id);
    if (index == -1) return;
    final obj = objects[index];
    if (obj.state != GameObjectState.flying) return;

    // 🔥 FIXED: Play bomb sound here, no gameover sound
    if (obj.type == GameObjectType.bomb) {
      HapticFeedback.heavyImpact();
      if (_sfxOn) _sound.playSound(kBombSound, volume: _sfxVolume);
      _lives = 0;
      await _triggerGameOver();
      return;
    }

    obj.state = GameObjectState.sliced;
    HapticFeedback.lightImpact();
    obj.sliceOffsetX = touchX;
    obj.sliceOffsetY = touchY;
    obj.sliceVelocityX = (_rng.nextDouble() - 0.5) * 300;
    obj.sliceVelocityY = 650 + _rng.nextDouble() * 150;

    _increaseCombo();
    int bonus = _getComboBonus();
    lastBonus = bonus;
    _score += obj.score + bonus;

    if (_score > _highScore) {
      _highScore = _score;
      UserService.instance.setHighScore(_highScore);
    }

    _updateLevel();

    if (_sfxOn && obj.soundPath != null) {
      _sound.playSound(obj.soundPath!, volume: _sfxVolume);
    }
    notifyListeners();
  }

  void _startLoops() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    _scheduleSpawn();
  }

  void _stopLoops() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
  }

  void _tick() {
    if (_gameState != GameState.playing) return;
    final now = DateTime.now();
    final rawDt = _lastFrame == null ? 0.016 : now.difference(_lastFrame!).inMicroseconds / 1e6;
    final dt = rawDt * _timeScale;
    _lastFrame = now;

    final toRemove = <String>[];

    for (final obj in objects) {
      if (obj.state == GameObjectState.flying) {
        Physics.updateObject(obj, dt, _screenSize.height);
        if (obj.y < -120) {
          obj.state = GameObjectState.missed;
          if (obj.type == GameObjectType.face) {
            HapticFeedback.mediumImpact();
            _combo = 0;
            _lives--;
            if (_sfxOn) _sound.playSound(kMissSound, volume: _sfxVolume);
            
            // 🔥 FIXED: Play gameover sound ONLY when lives reach 0 by missing
            if (_lives <= 0) {
              if (!_isGameOverTriggered) {
                if (_sfxOn) _sound.playSound(kGameOverSound, volume: _sfxVolume);
                _triggerGameOver();
              }
              return;
            }
          }
          toRemove.add(obj.id);
        }
      } else if (obj.state == GameObjectState.sliced) {
        Physics.updateSlice(obj, dt);
        if (obj.y < -200) toRemove.add(obj.id);
      }
    }

    objects.removeWhere((o) => toRemove.contains(o.id));
    notifyListeners();
  }

  void _scheduleSpawn() {
    final baseDelay = AppConstants.minSpawnInterval + _rng.nextDouble() * (AppConstants.maxSpawnInterval - AppConstants.minSpawnInterval);
    final delay = baseDelay * _spawnDelayMultiplier();
    _spawnTimer = Timer(Duration(milliseconds: (delay * 1000).toInt()), () {
      if (_gameState == GameState.playing) {
        _spawnWave();
        _scheduleSpawn();
      }
    });
  }

  void _spawnWave() {
    if (objects.length > 10) return;

    final sw = _screenSize.width;
    if (_level >= 2 && _rng.nextDouble() < 0.25) {
      _spawnBombAt(sw / 2 + (_rng.nextDouble() - 0.5) * 200);
      return; 
    }

    final count = min(3, 1 + (_level ~/ 3) + _rng.nextInt(2));
    final pattern = _rng.nextInt(3);
    List<double> positions = [];

    if (pattern == 0) {
      for (int i = 0; i < count; i++) positions.add(80 + i * ((sw - 160) / count));
    } else if (pattern == 1) {
      double center = sw / 2;
      for (int i = 0; i < count; i++) positions.add(center + (_rng.nextDouble() - 0.5) * 120);
    } else {
      for (int i = 0; i < count; i++) {
        double x; bool safe; int tries = 0;
        do {
          x = 80 + _rng.nextDouble() * (sw - 160); safe = true;
          for (final px in positions) { if ((px - x).abs() < 90) { safe = false; break; } }
          tries++;
        } while (!safe && tries < 10);
        positions.add(x);
      }
    }
    for (int i = 0; i < positions.length; i++) _spawnFaceAt(positions[i]);
  }

  void _spawnFaceAt(double x) {
    final face = kFaces[_rng.nextInt(kFaces.length)];
    objects.add(GameObject(id: 'obj_${_idCounter++}', type: GameObjectType.face, imagePath: face.image, leftPath: face.left, rightPath: face.right, soundPath: face.sound, score: face.score, x: x, y: 0, velocityX: Physics.getVelocityX(_rng), velocityY: Physics.getVelocityY(_rng, _speedMultiplier()), size: 90));
  }

  void _spawnBombAt(double x) {
    objects.add(GameObject(id: 'obj_${_idCounter++}', type: GameObjectType.bomb, imagePath: kBombImage, x: x, y: 0, velocityX: Physics.getVelocityX(_rng), velocityY: Physics.getVelocityY(_rng, _speedMultiplier()), size: 80));
  }
}