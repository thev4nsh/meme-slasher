import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version')
          .get();

      final data = doc.data();
      if (data == null) return;

      final latest = data['latest_version'] ?? "";
      final url = data['update_url'] ?? "";
      final videoUrl = data['how_to_download_video'] ?? "";

      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      if (current != latest) {
        if (!context.mounted) return;
        _showForceUpdateDialog(context, url, videoUrl);
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  static void _showForceUpdateDialog(
      BuildContext context, String url, String videoUrl) {
    showDialog(
      context: context,
      barrierDismissible: false, // ❌ cannot close
      builder: (_) => PopScope(
        canPop: false, // ❌ back button disabled
        child: AlertDialog(
          title: const Text("Update Required"),
          content: const Text(
            "You must update the app to continue playing.",
          ),
          actions: [
            /// 🎥 HOW TO DOWNLOAD (OPTIONAL)
            if (videoUrl.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(videoUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: const Text("How to Download"),
              ),

            /// 🔥 UPDATE BUTTON (ONLY OPTION)
            ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}