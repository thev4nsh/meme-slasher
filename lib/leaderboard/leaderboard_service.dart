import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/user_service.dart';

class LeaderboardService {
  final _db = FirebaseFirestore.instance;

  // 🔥 SAVE SCORE
  Future<void> submitScore(int score) async {
    final user = UserService.instance;
    await user.init();

    await _db.collection('leaderboard').add({
      'name': user.username.isNotEmpty
          ? user.username
          : user.userId,
      'userId': user.userId,
      'score': score,
      'time': FieldValue.serverTimestamp(),
    });
  }

  // 🔥 GET TOP 10
  Stream<QuerySnapshot> getTop10() {
    return _db
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots();
  }
}