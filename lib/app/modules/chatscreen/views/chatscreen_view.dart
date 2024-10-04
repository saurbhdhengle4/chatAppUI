import 'package:chatapp/app/data/msg_model.dart';
import 'package:chatapp/app/data/user_data_model.dart';
import 'package:chatapp/app/modules/chatscreen/controllers/chatscreen_controller.dart';
import 'package:chatapp/app/modules/chatscreen/views/image_view.dart';
import 'package:chatapp/app/modules/chatscreen/views/video_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatscreenView extends GetView<ChatscreenController> {
  final UserModel user;
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatscreenView(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatscreenController());
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(user.name.capitalizeFirst!,style: GoogleFonts.roboto()),
      ),
      bottomNavigationBar: sendTile(),
      body: GetBuilder<ChatscreenController>(
        builder: (controller) {
          return StreamBuilder<List<MessageModel>>(
            stream: controller.getMessages(user.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching messages"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No messages yet."));
              }
              final messages = snapshot.data!.reversed.toList();

              if (messages.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                });
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  bool isSender = message.senderId ==
                      FirebaseAuth.instance.currentUser!.uid;
                  return Row(
                    mainAxisAlignment: isSender
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSender
                                ? const Color(0xFFC4DFDF)
                                : const Color(0xFFC9DABF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black54,width: 0.25)
                          ),
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(isSender
                                  ? "You"
                                  : user.name.capitalizeFirst!,style: GoogleFonts.roboto(fontSize: 10),),
                              const SizedBox(height: 4),
                              message.type == 'image'
                                  ? GestureDetector(
                                      onTap: () {
                                        Get.to(() => FullScreenImageView(
                                            message.mediaUrl));
                                      },
                                      child: Image.network(
                                        message.mediaUrl ?? "",
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : message.type == 'video'
                                      ? GestureDetector(
                                          onTap: () {
                                            Get.to(() => FullScreenVideoView(
                                                message.mediaUrl));
                                          },
                                          child: Container(
                                            // height: 200,
                                            width: 200,
                                            // color: Colors.grey,
                                            child: const Icon(Icons.videocam,
                                                size: 50,color: Colors.grey,),
                                          ),
                                        )
                                      : Text(message.message,style: GoogleFonts.roboto(fontSize: 15)),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Padding sendTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              controller.pickAndSendImage(user.userId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              controller.pickAndSendVideo(user.userId);
            },
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration:  InputDecoration(
                hintText: "Type your message...",
                hintStyle:  GoogleFonts.roboto(fontSize: 15,color: Colors.grey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              String message = messageController.text.trim();
              if (message.isNotEmpty) {
                controller.sendMessage(user.userId, message);
                messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
