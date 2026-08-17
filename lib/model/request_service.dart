import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_request.dart';

class RequestService {
  final _db = FirebaseFirestore.instance;

  Stream<List<ItemRequest>> getRequestsStream() {
    return _db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ItemRequest.fromFirestore(doc)).toList());
  }

  Future<void> updateStatus(String requestId, String status) async {
    await _db.collection('requests').doc(requestId).update({'status': status});
  }

  Future<void> addRequest(ItemRequest request) async {
    await _db.collection('requests').add(request.toMap());
  }

  Stream<bool> isItemReservedStream(String itemId) {
    return getRequestsStream().map(
        (requests) => requests.any((r) => r.itemId == itemId && r.status == 'approved'));
  }

  Future<bool> isItemReserved(String itemId) async {
    final snapshot = await _db
        .collection('requests')
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'approved')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}