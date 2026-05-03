import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_provider.dart';
import '../constants/app_constants.dart';
import '../screens/home_screen.dart';

class PauseMenu extends StatefulWidget {
  const PauseMenu({super.key});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
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
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A003A), Color(0xFF0A001F)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF2D7A).withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(color: const Color(0xFFFF2D7A).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(AppConstants.instaUrl)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppConstants.instaAsset, width: 22, height: 22),
                    const SizedBox(width: 8),
                    Text('@${AppConstants.instaId}', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFE1306C), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('PAUSED', style: GoogleFonts.pressStart2p(fontSize: 22, color: Colors.white, shadows: const [Shadow(color: Color(0xFFFF2D7A), blurRadius: 15)])),
              const SizedBox(height: 24),
              
              _MenuButton(label: '▶  RESUME', color: const Color(0xFF00CC44), onTap: () {
                Navigator.pop(context);
                gp.resumeGame();
              }),
              const SizedBox(height: 14),
              
              _ToggleButton(label: 'SFX', isOn: gp.sfxOn, onTap: () => gp.toggleSfx()),
              if (gp.sfxOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Slider(value: _currentSfx, min: 0, max: 1, activeColor: Colors.cyanAccent, onChanged: (v) {
                    setState(() => _currentSfx = v);
                    gp.setSfxVolume(v);
                  }),
                ),
                
              _ToggleButton(label: 'BG MUSIC', isOn: gp.bgMusicOn, onTap: () => gp.toggleBgMusic()),
              if (gp.bgMusicOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Slider(value: _currentBg, min: 0, max: 1, activeColor: Colors.deepPurpleAccent, onChanged: (v) {
                    setState(() => _currentBg = v);
                    gp.setBgVolume(v);
                  }),
                ),
                
              _MenuButton(label: '✕  EXIT', color: const Color(0xFFFF2D7A), onTap: () {
                gp.exitToHome();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(label, style: GoogleFonts.pressStart2p(fontSize: 13, color: color))),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isOn;
  final VoidCallback onTap;
  const _ToggleButton({required this.label, required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isOn ? Colors.white : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(label, style: GoogleFonts.pressStart2p(fontSize: 11, color: color)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 42,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isOn ? const Color(0xFF00CC44) : Colors.white24,
                ),
                child: Align(
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}