import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0000), Color(0xFF0A0010), Color(0xFF000510)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFFFF0000), Color(0xFFFF6B35)],
                  ).createShader(b),
                  child: Text(
                    'GAME OVER',
                    style: GoogleFonts.pressStart2p(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                _ScoreBox(label: 'SCORE', value: gp.score),
                const SizedBox(height: 12),
                _ScoreBox(label: 'BEST', value: gp.highScore, gold: true),
                const SizedBox(height: 56),
                _BigButton(
                  label: '↺  RESTART',
                  gradient: const [Color(0xFF00CC44), Color(0xFF00FF88)],
                  glowColor: const Color(0xFF00FF88),
                  onTap: () {
                    gp.restartGame();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _BigButton(
                  label: '✕  EXIT',
                  gradient: const [Color(0xFFCC0033), Color(0xFFFF2D7A)],
                  glowColor: const Color(0xFFFF2D7A),
                  onTap: () {
                    gp.exitToHome();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (_) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;
  final bool gold;
  const _ScoreBox({required this.label, required this.value, this.gold = false});

  @override
  Widget build(BuildContext context) {
    final color = gold ? Colors.amber : Colors.white;
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.pressStart2p(fontSize: 12, color: color.withValues(alpha: 0.7))),
          Text('$value', style: GoogleFonts.pressStart2p(fontSize: 18, color: color)),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;
  const _BigButton({required this.label, required this.gradient, required this.glowColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: glowColor.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white, letterSpacing: 2)),
        ),
      ),
    );
  }
}