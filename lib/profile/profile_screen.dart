import 'package:flutter/material.dart';
import 'user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = UserService.instance;
  final controller = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await user.init();
    controller.text = user.username;
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 SHOW NAME OR USER ID
            Text(
              user.username.isNotEmpty
                  ? user.username
                  : (user.userId ?? ""),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();

                if (newName.isEmpty) return;

                await user.updateName(newName);

                if (!mounted) return;

                setState(() {}); // 🔥 refresh UI

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Saved ✅")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}