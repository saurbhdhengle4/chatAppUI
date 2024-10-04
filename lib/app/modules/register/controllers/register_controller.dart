import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;

  RxBool isPasswordVisible = false.obs;

  Future<void> register(
      String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await updateUserProfile(displayName: displayName);
      // Store user data in Firestore
      await saveUserToFirestore(
        userId: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );
      // Get.offAndToNamed(Routes.SPLASHSCREEN);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'profilePicture': '',
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to save user data to Firestore");
    }
  }

  Future<void> updateUserProfile(
      {String? displayName, String? photoUrl}) async {
    try {
      await auth.currentUser!.updateDisplayName(displayName);
      await auth.currentUser!.updatePhotoURL(photoUrl);
      update();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
