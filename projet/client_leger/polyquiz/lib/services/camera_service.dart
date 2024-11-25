import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // Fonction pour capturer une photo
  Future<File?> takePhoto() async {
    try {
      // Ouvre la caméra et capture une image
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return File(photo.path); // Retourne le fichier photo
      }
    } catch (e) {
      debugPrint('Erreur lors de la capture de la photo : $e');
    }
    return null; // Retourne null si aucune photo n'est prise
  }
}