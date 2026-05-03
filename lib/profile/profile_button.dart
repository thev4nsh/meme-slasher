import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'user_service.dart';

class ProfileButton extends StatefulWidget {
  const ProfileButton({super.key});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  final user = UserService.instance;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await user.init();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 12,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );

          setState(() {}); // 🔥 refresh after return
        },
        child: Row(
          children: [
            // 👤 ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),

            const SizedBox(width: 8),

            // 🧾 NAME + ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username.isNotEmpty
                      ? user.username
                      : (user.userId ?? ""),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.username.isNotEmpty)
                  Text(
                    user.userId ?? "",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}