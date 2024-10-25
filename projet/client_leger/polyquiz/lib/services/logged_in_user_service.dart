import 'package:polyquiz/models/user.dart';

class LoggedInUserService {
  // Singleton instance
  static final LoggedInUserService _instance = LoggedInUserService._internal();

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

  User? getUser(){
    return (this.user);
  }
  String? getUid(){
    return (this.user?.uid);
  }
}
