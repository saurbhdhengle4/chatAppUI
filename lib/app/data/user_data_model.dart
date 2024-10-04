import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String name;
  final String? profilePicture;
  final bool isOnline;
  final DateTime? lastSeen;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.isOnline,
    this.lastSeen,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      name: data['displayName'] ?? '',
      profilePicture: data['profilePicture'],
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }
}
