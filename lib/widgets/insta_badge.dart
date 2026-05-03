import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class InstaBadge extends StatelessWidget {
  final bool clickable;
  const InstaBadge({super.key, this.clickable = true});

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE1306C).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE1306C).withValues(alpha: 0.25),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppConstants.instaAsset, width: 20, height: 20),
          const SizedBox(width: 7),
          Text(
            '@${AppConstants.instaId}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFE1306C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (!clickable) return badge;

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(AppConstants.instaUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: badge,
    );
  }
}
