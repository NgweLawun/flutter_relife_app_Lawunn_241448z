import 'package:cloud_firestore/cloud_firestore.dart';
class Item {
  final String id; 
  final String title;
  final String description;
  final String imageUrl;
  final String category; //
  final String pickupLocation; // 
  final String ownerId; // Firebase UID of the person who posted it
  final String ownerEmail; // for display without an extra lookup
  final DateTime? createdAt; //

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.pickupLocation,
    required this.ownerId,
    required this.ownerEmail,
    this.createdAt,
  });

  // NEW: build an Item from a Firestore document
  factory Item.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Item(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      pickupLocation: data['pickupLocation'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // NEW: convert an Item into a Map for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'pickupLocation': pickupLocation,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}