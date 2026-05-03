import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LeaderboardService();

    return Scaffold(
      appBar: AppBar(title: const Text("🏆 Leaderboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getTop10(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No scores yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i];

              return ListTile(
                leading: Text(
                  "#${i + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['userId'] ?? ''),
                trailing: Text(
                  data['score'].toString(),
                  style: const TextStyle(fontSize: 18),
                ),
              );
            },
          );
        },
      ),
    );
  }
}