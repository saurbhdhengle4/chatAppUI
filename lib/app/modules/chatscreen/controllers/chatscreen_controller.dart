import 'dart:io';
import 'package:chatapp/app/data/msg_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ChatscreenController extends GetxController {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> pickAndSendImage(String userId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Image picked: ${image.path}"); // Debugging output
      String mediaUrl = await uploadFile(image.path);
      print("Media URL: $mediaUrl"); // Debugging output
      if (mediaUrl.isNotEmpty) {
        // Check if mediaUrl is valid
        sendMessage(userId, 'Image sent', mediaUrl: mediaUrl, type: 'image');
      } else {
        Get.snackbar("Error", "Failed to get media URL.");
      }
    } else {
      Get.snackbar("Error", "No image selected.");
    }
  }

  Future<void> pickAndSendVideo(String userId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      print("Video picked: ${video.path}"); // Debugging output
      String mediaUrl = await uploadFile(video.path);
      print("Media URL: $mediaUrl"); // Debugging output
      if (mediaUrl.isNotEmpty) {
        // Check if mediaUrl is valid
        sendMessage(userId, 'Video sent', mediaUrl: mediaUrl, type: 'video');
      } else {
        Get.snackbar("Error", "Failed to get media URL.");
      }
    } else {
      Get.snackbar("Error", "No video selected.");
    }
  }

  Future<String> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = file.path.split('/').last;
      Reference ref = storage.ref().child('messages/$fileName');
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to upload file: ${e.toString()}");
      return '';
    }
  }

  void sendMessage(String userId, String message,
      {String? mediaUrl, String type = 'text'}) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar("Error", "User is not authenticated.");
      return;
    }
    FirebaseFirestore.instance.collection('chats').add({
      'senderId': currentUser.uid,
      'receiverId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'mediaUrl': mediaUrl,
    }).then((_) {
      // Notify listeners to update UI after sending message
      update();
    }).catchError((error) {
      Get.snackbar("Error", "Failed to send message: ${error.toString()}");
    });
  }

  Stream<List<MessageModel>> getMessages(String userId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chats')
        .where('senderId', isEqualTo: currentUserId)
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromDocument(doc)).toList())
        .asyncExpand((messages) {
      return FirebaseFirestore.instance
          .collection('chats')
          .where('senderId', isEqualTo: userId)
          .where('receiverId', isEqualTo: currentUserId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromDocument(doc))
              .toList())
          .map((incomingMessages) => messages + incomingMessages);
    });
  }
}
