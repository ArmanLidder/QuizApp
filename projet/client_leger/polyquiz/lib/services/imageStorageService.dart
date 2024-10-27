import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    final Reference ref = _storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(image.path));
    String link =await ref.getDownloadURL();
    return link;
  }
}
