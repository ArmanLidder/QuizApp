import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  Rx<String> photoImageUrl = Rx<String>("");

  Future<String?> uploadImage(File image) async {
    final Reference ref = _storage.ref().child('images/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    String link = await ref.getDownloadURL();
    photoImageUrl.value = link;
    return link;
  }
  Future<String?> pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    final Reference ref = _storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(image.path));
    String link = await ref.getDownloadURL();
    photoImageUrl.value = link;
    return link;
  }
}
