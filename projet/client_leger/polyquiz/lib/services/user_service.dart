import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserService extends GetxController {
  final String collectionName = 'users';
  static UserService get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String id) async {
    final doc = await _db.collection(collectionName).doc(id).get();
    return doc;
  }
}