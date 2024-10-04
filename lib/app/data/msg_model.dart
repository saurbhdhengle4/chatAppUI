import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String message;
  final String type;
  final String? mediaUrl;
  final Timestamp timestamp;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    this.mediaUrl,
    required this.timestamp,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    return MessageModel(
      senderId: doc['senderId'] ?? '',
      receiverId: doc['receiverId'] ?? '',
      message: doc['message'] ?? '',
      type: doc['type'] ?? 'text',
      mediaUrl: doc['mediaUrl'],
      timestamp: doc['timestamp'] ?? Timestamp.now(),
    );
  }
}
