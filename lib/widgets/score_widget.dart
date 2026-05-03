import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ScoreWidget extends StatefulWidget {
  const ScoreWidget({super.key});

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget>
    with SingleTickerProviderStateMixin {

  double _bonusOpacity = 0;
  int _bonusValue = 0;

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    // 🔥 trigger animation
    if (gp.lastBonus > 0) {
      _bonusValue = gp.lastBonus;
      _bonusOpacity = 1;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _bonusOpacity = 0;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SCORE',
          style: GoogleFonts.pressStart2p(
            fontSize: 8,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          '${gp.score}',
          style: GoogleFonts.pressStart2p(
            fontSize: 22,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.cyanAccent, blurRadius: 12)
            ],
          ),
        ),

        // 🔥 BONUS TEXT
        AnimatedOpacity(
          opacity: _bonusOpacity,
          duration: const Duration(milliseconds: 300),
          child: Transform.translate(
            offset: Offset(0, -_bonusOpacity * 10),
            child: Text(
              '+$_bonusValue BONUS',
              style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.yellowAccent,
                shadows: const [
                  Shadow(color: Colors.orange, blurRadius: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}