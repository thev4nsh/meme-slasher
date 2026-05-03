import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/insta_badge.dart';
import 'game_screen.dart';
import '../profile/profile_button.dart';
import '../leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _welcomePlayed = false; // 🔥 Prevents it from playing twice on screen rebuild

  @override
  void initState() {
    super.initState();
    // Delay slightly so the audio engine is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_welcomePlayed) {
        context.read<GameProvider>().playWelcomeSound();
        _welcomePlayed = true;
      }
    });
  }

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
                colors: [Color(0xFF0A0015), Color(0xFF1A0035), Color(0xFF000A1A)],
              ),
            ),
          ),
          const _StarField(),

          Positioned(
            top: 40, right: 16,
            child: GestureDetector(
              onTap: () => showDialog(context: context, builder: (_) => const _SettingsDialog()),
              child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: Colors.white24)), child: const Icon(Icons.settings, color: Colors.white)),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF2D7A), Color(0xFFFF9F1C), Color(0xFFFFFF00)]).createShader(bounds),
                  child: Text('NINJA', style: GoogleFonts.pressStart2p(fontSize: 54, color: Colors.white, shadows: const [Shadow(color: Colors.red, blurRadius: 30), Shadow(color: Colors.orange, blurRadius: 60)])),
                ),
                const SizedBox(height: 12),
                Text('⚔  KAATO ⚔', style: GoogleFonts.pressStart2p(fontSize: 11, color: Colors.white54, letterSpacing: 4)),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1.5), borderRadius: BorderRadius.circular(8), color: Colors.amber.withValues(alpha: 0.05)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events, color: Colors.amber, size: 22), const SizedBox(width: 10), Text('BEST  ${gp.highScore}', style: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.amber))]),
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () { gp.startGame(); Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())); },
                  child: Container(width: 220, height: 64, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF2D7A), Color(0xFFFF6B35)]), borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: const Color(0xFFFF2D7A).withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 4)]), child: Center(child: Text('▶  PLAY', style: GoogleFonts.pressStart2p(fontSize: 16, color: Colors.white, letterSpacing: 3)))),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                  child: Container(width: 220, height: 50, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white30), color: Colors.white.withValues(alpha: 0.08)), child: Center(child: Text('🏆 LEADERBOARD', style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white, letterSpacing: 2)))),
                ),
              ],
            ),
          ),
          const Positioned(left: 16, bottom: 24, child: InstaBadge(clickable: true)),
          const ProfileButton(),
        ],
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarPainter());
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final stars = [[0.1, 0.05, 1.5], [0.25, 0.12, 1.0], [0.6, 0.08, 2.0], [0.8, 0.15, 1.2], [0.4, 0.3, 1.8], [0.9, 0.4, 1.0], [0.15, 0.55, 1.5], [0.7, 0.6, 1.3], [0.35, 0.75, 2.0], [0.85, 0.85, 1.0], [0.5, 0.9, 1.5], [0.05, 0.9, 1.2]];
    for (final s in stars) {
      paint.color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(size.width * s[0], size.height * s[1]), s[2], paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _SettingsDialog extends StatefulWidget {
  const _SettingsDialog();
  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  double _currentSfx = 0;
  double _currentBg = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gp = context.watch<GameProvider>();
    _currentSfx = gp.sfxVolume;
    _currentBg = gp.bgVolume;
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    return Dialog(
      backgroundColor: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SETTINGS", style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 20),
              SwitchListTile(title: const Text("Sound Effects", style: TextStyle(color: Colors.white)), value: gp.sfxOn, onChanged: (_) => gp.toggleSfx()),
              if (gp.sfxOn) Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(children: [const Text("SFX Vol", style: TextStyle(color: Colors.white54, fontSize: 12)), Expanded(child: Slider(value: _currentSfx, min: 0, max: 1, activeColor: Colors.cyanAccent, onChanged: (v) { setState(() => _currentSfx = v); gp.setSfxVolume(v); }))])),
              const SizedBox(height: 10),
              SwitchListTile(title: const Text("Background Music", style: TextStyle(color: Colors.white)), subtitle: const Text("Turn OFF for Spotify", style: TextStyle(color: Colors.white54, fontSize: 11)), value: gp.bgMusicOn, onChanged: (_) => gp.toggleBgMusic()),
              if (gp.bgMusicOn) Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Row(children: [const Text("Music Vol", style: TextStyle(color: Colors.white54, fontSize: 12)), Expanded(child: Slider(value: _currentBg, min: 0, max: 1, activeColor: Colors.deepPurpleAccent, onChanged: (v) { setState(() => _currentBg = v); gp.setBgVolume(v); }))])),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }
}