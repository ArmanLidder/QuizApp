import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ValidationService extends GetxController{
  static ValidationService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isValidUsername(String username) async {
    if (username.length < 1 || username.length > 10) {
      return false;
    }
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regExp.hasMatch(username)) {
      return false;
    }
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (result.docs.isNotEmpty) {
      return false;
    }
    return true;
  }

  bool isValidAddress(String email) {
    return email.contains('@') && email.contains('.');
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
