import 'package:chatapp/app/data/user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              user.profilePicture != ""
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.profilePicture ?? ""),
                    )
                  : const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
              const SizedBox(height: 16),
              Text(user.name.capitalizeFirst!,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(user.email, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(user.isOnline ? "Online" : "Last seen: ${user.lastSeen}",
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
