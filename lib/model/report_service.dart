import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;

  static const suspensionThreshold = 3;

  Future<void> reportPost({
    required String itemId,
    required String ownerId,
    required String reason,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    if (user.uid == ownerId) throw Exception("You can't report your own post");

    // Deterministic ID so a given reporter can only report a given post once.
    final reportRef = _db.collection('reports').doc('${itemId}_${user.uid}');
    final existing = await reportRef.get();
    if (existing.exists) throw Exception("You've already reported this post");

    await reportRef.set({
      'itemId': itemId,
      'ownerId': ownerId,
      'reporterId': user.uid,
      'reporterEmail': user.email ?? '',
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final ownerReports =
        await _db.collection('reports').where('ownerId', isEqualTo: ownerId).get();

    if (ownerReports.docs.length >= suspensionThreshold) {
      await _db.collection('users').doc(ownerId).set(
        {'suspended': true},
        SetOptions(merge: true),
      );
    }
  }
}
