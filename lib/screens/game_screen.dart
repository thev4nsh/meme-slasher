import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../models/game_object.dart';
import '../widgets/sliceable_face.dart';
import '../widgets/heart_widget.dart';
import '../widgets/score_widget.dart';
import '../widgets/pause_menu.dart';
import '../constants/app_constants.dart';
import 'game_over_screen.dart';
import '../widgets/swipe_trail.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigated = false;
  final ValueNotifier<List<Offset>> _trailNotifier = ValueNotifier([]);
  
  // Screen Shake Variables
  double _shakeX = 0;
  double _shakeY = 0;

  @override
  void dispose() {
    _trailNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    context.read<GameProvider>().setScreenSize(size);
  }

  void _triggerShake() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        final gp = context.read<GameProvider>();
        if (gp.gameState == GameState.gameOver) {
          setState(() { _shakeX = 0; _shakeY = 0; });
          return;
        }
        setState(() {
          _shakeX = (Random().nextDouble() - 0.5) * 16;
          _shakeY = (Random().nextDouble() - 0.5) * 16;
        });
        _triggerShake();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gp   = context.watch<GameProvider>();
    final size = MediaQuery.of(context).size;

    if (gp.gameState == GameState.gameOver && !_navigated) {
      _navigated = true;
      Future.microtask(() {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameOverScreen()));
      });
    }

    return Scaffold(
      body: Transform.translate(
        offset: Offset(_shakeX, _shakeY), // 🔥 SCREEN SHAKE
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF050010), Color(0xFF100020), Color(0xFF000510)]),
              ),
            ),

            ...gp.objects.map((obj) => SliceableFace(key: ValueKey(obj.id), object: obj, screenSize: size)),

            IgnorePointer(
              child: ValueListenableBuilder<List<Offset>>(
                valueListenable: _trailNotifier,
                builder: (context, points, _) => SwipeTrail(points: points),
              ),
            ),

            GestureDetector(
              onPanUpdate: (details) {
                final points = List<Offset>.from(_trailNotifier.value);
                points.add(details.localPosition);
                if (points.length > 15) points.removeAt(0);
                _trailNotifier.value = points; 
                _checkSlice(details.localPosition, gp, size);
              },
              onPanEnd: (_) => _trailNotifier.value = [],
              child: SizedBox.expand(child: Container(color: Colors.transparent)),
            ),

            const Positioned(top: 48, left: 16, child: ScoreWidget()),
            Positioned(
  top: 44,
  left: 0,
  right: 0,
  child: Center(
    child: HeartWidget(lives: gp.lives),
  ),
),
            
            Positioned(
              top: 40, right: 16,
              child: GestureDetector(
                onTap: () { gp.pauseGame(); showDialog(context: context, barrierDismissible: false, builder: (_) => const PauseMenu()); },
                child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white24)), child: const Icon(Icons.pause, color: Colors.white, size: 22)),
              ),
            ),
            Positioned(bottom: 16, right: 12, child: _Watermark()),
          ],
        ),
      ),
    );
  }

  void _checkSlice(Offset touch, GameProvider gp, Size size) {
    for (final obj in gp.objects) {
      if (obj.state != GameObjectState.flying) continue;
      final screenY = size.height - obj.y;
      final dx = touch.dx - obj.x;
      final dy = touch.dy - screenY;
      final dist = dx * dx + dy * dy;
      final radius = (obj.size / 2) * 1.2;
      if (dist <= radius * radius) {
        if (obj.type == GameObjectType.bomb) _triggerShake(); // 🔥 TRIGGER SHAKE
        gp.onSlice(obj.id, touch.dx, touch.dy, size);
        break;
      }
    }
  }
}

class _Watermark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.black.withOpacity(0.3), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)]),
      child: Text(AppConstants.watermark, style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.blueAccent.withOpacity(0.45), shadows: [Shadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 8)])),
    );
  }
}