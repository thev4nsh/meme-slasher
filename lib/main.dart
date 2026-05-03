import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'services/update_service.dart';
import 'services/notification_service.dart';

/// 🔥 BACKGROUND HANDLER (TOP LEVEL)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final service = NotificationService();
  await service.init();
  await service.showNotification(
    title: message.notification?.title ?? "Ninja Kaato",
    body: message.notification?.body ?? "New message!",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Firebase.initializeApp();

  /// 🔥 REGISTER BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  /// 🔥 INIT NOTIFICATION SERVICE
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const NinjaGameApp(),
    ),
  );
}

class NinjaGameApp extends StatelessWidget {
  const NinjaGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ninja Game',
      theme: ThemeData.dark(),
      home: const _AppInitializer(),
    );
  }
}

class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_tutorial') ?? false;

    if (!seen) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _showTutorial = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_showTutorial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showTutorialDialog(context);
          });
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          UpdateService.checkForUpdate(context);
        });

        return const HomeScreen();
      },
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe, color: Colors.orange, size: 50),
              const SizedBox(height: 16),
              const Text(
                "HOW TO PLAY",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Swipe across the faces to slice them!\nAvoid the bombs. 💣",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('seen_tutorial', true);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  "GOT IT!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}