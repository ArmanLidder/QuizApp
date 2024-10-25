import 'package:polyquiz/models/user.dart';
import 'package:get/get.dart';
import 'user_service.dart';
class LoggedInUserService {
  // Singleton instance
  static final LoggedInUserService _instance = LoggedInUserService._internal();

  static LoggedInUserService get instance => Get.find();

  // User properties
  User? user;

  // Private constructor
  LoggedInUserService._internal();

  // Getter for the singleton instance
  factory LoggedInUserService() {
    return _instance;
  }

  // Method to set user info
  void setUser(User user) {
    this.user = user;
  }

  Future<void> setUserByEmail(String email) async {
    final userService = UserService.instance; // Access UserService instance
    User? fetchedUser = await userService.getUserByEmail(email); // Fetch user by email
    if (fetchedUser != null) {
      setUser(fetchedUser); // Set the fetched user
    } else {
      print('User not found with email: $email');
    }
  }

  User? getUser(){
    return (this.user);
  }
  String? getUid(){
    return (this.user?.uid);
  }
}
