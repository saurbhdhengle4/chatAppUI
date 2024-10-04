import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final String? imageUrl;

  const FullScreenImageView(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(imageUrl ?? ""),
      ),
    );
  }
}
