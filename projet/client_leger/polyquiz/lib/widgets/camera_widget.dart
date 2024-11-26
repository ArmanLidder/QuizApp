import 'package:flutter/material.dart';
import 'package:polyquiz/services/camera_service.dart';
import 'dart:io';

import 'package:polyquiz/services/imageStorageService.dart';

class CameraWidget extends StatefulWidget {
  final Function(String) onImageCaptured;

  CameraWidget({required this.onImageCaptured});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  final CameraService cameraService = CameraService();
  File? image;

  void _takePhoto() async {
    File? newImage = await cameraService.takePhoto();
    if (newImage != null) {
      setState(() {
        image = newImage;
      });
      String? firebasePath = await ImageStorageService().uploadImage(image!);
      widget.onImageCaptured(firebasePath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image != null
                  ? Image.file(image!)
                  : Text('No image taken'),
              SizedBox(height: 20),
              IconButton(
                icon: Icon(Icons.camera_alt),
                iconSize: 50,
                color: Colors.blue,
                onPressed: _takePhoto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}