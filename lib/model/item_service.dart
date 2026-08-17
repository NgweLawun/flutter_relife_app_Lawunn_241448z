import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'item.dart';

class ItemService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<List<Item>> getItemsStream() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList());
  }

  
  Future<String> uploadImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user?.uid}.jpg';
    final ref = _storage.ref().child('item_images/$fileName');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> addItem({
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required String pickupLocation,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _db.collection('items').add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'pickupLocation': pickupLocation,
      'ownerId': user.uid,
      'ownerEmail': user.email ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String itemId,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    required String pickupLocation,
  }) async {
    await _db.collection('items').doc(itemId).update({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'pickupLocation': pickupLocation,
    });
  }

  Future<void> deleteItem(String itemId) async {
    final requestsSnapshot =
        await _db.collection('requests').where('itemId', isEqualTo: itemId).get();

    final batch = _db.batch();
    for (final doc in requestsSnapshot.docs) {
      batch.update(doc.reference, {'status': 'removed'});
    }
    batch.delete(_db.collection('items').doc(itemId));
    await batch.commit();
  }
}