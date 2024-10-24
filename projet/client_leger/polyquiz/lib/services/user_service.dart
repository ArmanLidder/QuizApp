import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/user.dart';

class UserService extends GetxController {
  final String collectionName = 'users';
  static UserService get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<User?> getUserById(String id) async {
    final doc = await _db.collection(collectionName).doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    final user = User.fromJson(doc.data()!);
    return user;
  }
}