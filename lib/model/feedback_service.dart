import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final _db = FirebaseFirestore.instance;

  Future<void> submitFeedback({
    required String message,
    required int rating,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _db.collection('feedback').add({
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'message': message,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
