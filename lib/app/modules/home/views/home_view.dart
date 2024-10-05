import 'package:chatapp/app/modules/chatscreen/views/chatscreen_view.dart';
import 'package:chatapp/app/modules/home/views/user_details_screen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Chat App',style: GoogleFonts.roboto(fontSize: 30,fontWeight: FontWeight.w600,color: Colors.black87),),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
              onTap: () {
                controller.signOut();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: Icon(Icons.logout_rounded),
              ))
        ],
      ),
      body: Obx(() {
        if (controller.userList.isEmpty) {
          return const Center(child: Text("Data Not Found"));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.userList.length,
            itemBuilder: (context, index) {
              final user = controller.userList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                   onTap: () {
                      Get.to(() => ChatscreenView(user));
                    },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF4F5),
                      border: Border.all(color: Colors.grey, width: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => UserDetailScreen(user: user));
                            },
                            child: user.profilePicture != ""
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.profilePicture ?? ""),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.capitalizeFirst!,
                                  style: GoogleFonts.roboto(fontSize: 15),
                                ),
                                Text(
                                  user.email,
                                  style: GoogleFonts.roboto(fontSize: 12),
                                ),
                                Text(
                                  user.isOnline
                                      ? "Online"
                                      : "Last seen: ${user.lastSeen}",
                                  style: GoogleFonts.roboto(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
