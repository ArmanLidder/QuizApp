import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/models/user.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'user_service.dart';

class LoggedInUserService extends GetxController {
  static LoggedInUserService get instance => Get.find();
  final UserService userService = UserService();
  final ImageStorageService imageStorageService = ImageStorageService();
  late var observableCurrency = 0.obs;
  late var observableAvatar = ''.obs;
  User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to set user info
  void setUser(User? user) {
    this.user = user;
    this.observableCurrency.value = (this.user?.currency ?? 0).round();
    this.observableAvatar.value = (this.user?.avatar ?? "");
  }

  Future<void> setUserByEmail(String email) async {
    User? fetchedUser = await this.userService.getUserByEmail(email); // Fetch user by email
    if (fetchedUser != null) {
      setUser(fetchedUser); // Set the fetched user
    } else {
      print('User not found with email: $email');
    }
  }
  Future<void> login(String email) async {
    // Fetch and set the user by email
    await setUserByEmail(email);

    // Get the user object (assuming `userService.user` holds the current user)
    User? currentUser = this.user;

    // Check if the user was successfully set
    if (currentUser != null) {
      // Update the `isOnline` status in Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isConnected': true});

      // Retrieve current loginHistory, add new event, and update in Firebase
      DocumentReference userDocRef = _firestore.collection('users').doc(currentUser.uid);
      DocumentSnapshot userSnapshot = await userDocRef.get();

      List<dynamic> loginHistory = userSnapshot.get('loginHistory') ?? [];
      Timestamp timestamp = Timestamp.now(); // Get the current timestamp
      loginHistory.add({
        'eventType': 'login',
        'timestamp': timestamp,
      });
      await userDocRef.update({'loginHistory': loginHistory});
      await reloadUser();
    } else {
      print('Login failed: user not found with email $email');
    }
  }
  Future<void> reloadUser() async {
    String? uid = await this.getUid();
    User? user = await UserService.instance.getUserById(uid ?? '');
    this.setUser(user);
  }

  User? getUser() {
    return (this.user);
  }

  String? getUid() {
    if (this.user == null) {
      return "noUser";
    }
    return (this.user?.uid);
  }

  String forceToString(String? string) {
    if (string == null) {
      return "emptyString";
    }
    return string;
  }

  Future<void> uploadCustomProfilePicture() async {
    String? newImagelLink = await this.imageStorageService.pickAndUploadImage();
    this.observableAvatar.value = newImagelLink!;
    await this.userService.updateUserAvatar(
        id: this.forceToString(this.getUid()),
        newAvatarUrl: this.forceToString(newImagelLink));
    await this.reloadUser();
  }

  Future<void> chooseNewProfilePicture(String newProfileUrl) async {
    this.observableAvatar.value = newProfileUrl;
    await this.userService.updateUserAvatar(
        id: this.forceToString(this.getUid()),
        newAvatarUrl: this.forceToString(newProfileUrl));
    await this.reloadUser();
  }
}