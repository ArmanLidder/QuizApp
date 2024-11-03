import 'dart:ui';

import 'package:polyquiz/models/user.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'user_service.dart';

class LoggedInUserService extends GetxController {
  static LoggedInUserService get instance => Get.find();
  final UserService userService = UserService();
  final ImageStorageService imageStorageService = ImageStorageService();

  User? user;

  // Method to set user info
  void setUser(User? user) {
    this.user = user;
  }

  Future<void> setUserByEmail(String email) async {
    
    User? fetchedUser = await this.userService.getUserByEmail(email); // Fetch user by email
    if (fetchedUser != null) {
      setUser(fetchedUser); // Set the fetched user
    } else {
      print('User not found with email: $email');
    }
  }
  Future<void> reloadUser() async{
    String? uid = await this.getUid();
    User? user = await UserService.instance.getUserById(uid ?? '');
    this.setUser(user);
  }
  User? getUser(){
    return (this.user);
  }
  String? getUid(){
    if (this.user == null){
      return "noUser";
    }
    return (this.user?.uid);
  }
String forceToString(String? string){
  if (string == null){
    return "emptyString";
  }
  return string;
}

  Future<void> updateProfilePicture() async{
    String? newImagelLink = await this.imageStorageService.pickAndUploadImage();
    await this.userService.updateUserAvatar(id: this.forceToString(this.getUid()), newAvatarUrl: this.forceToString(newImagelLink));
    await this.reloadUser();
  }
}
