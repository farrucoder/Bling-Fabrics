import 'package:flutter/material.dart';

class FullImageScreen extends StatelessWidget {
  final String imagePath;

  const FullImageScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.network(imagePath),
        ),
      ),
    );
  }
}
