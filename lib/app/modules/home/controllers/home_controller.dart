import 'package:chatapp/app/data/user_data_model.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  void signOut() async {
    await auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }

  var userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void fetchUsers() {
    // Get the current user's ID
    String currentUserId = auth.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) {
      userList.value = snapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .where((user) => user.userId != currentUserId)
          .toList();
    });
  }

  Future<void> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'userId': user.uid,
        'displayName': name,
        'email': email,
        'profilePicture': '',
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
