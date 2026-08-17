import 'package:cloud_firestore/cloud_firestore.dart';

class ItemRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final String ownerId;
  final String ownerEmail;

  final String requesterId;
  final String requesterEmail;
  final String collectTime;
  final String message;
  final int rating;
  final String status; // pending, approved, declined
  final DateTime? createdAt;

  ItemRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.ownerId,
    required this.ownerEmail,

    required this.requesterId,
    required this.requesterEmail,
    required this.collectTime,
    required this.message,
    required this.rating,
    required this.status,
    this.createdAt,
  });

  factory ItemRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemRequest(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      itemTitle: data['itemTitle'] ?? '',
      itemImageUrl: data['itemImageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterEmail: data['requesterEmail'] ?? '',
      collectTime: data['collectTime'] ?? '',
      message: data['message'] ?? '',
      rating: data['rating'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemImageUrl': itemImageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'requesterId': requesterId,
      'requesterEmail': requesterEmail,
      'collectTime': collectTime,
      'message': message,
      'rating': rating,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
