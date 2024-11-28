import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/models/user.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/camera_service.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/notification_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'user_service.dart';
import 'package:image_picker/image_picker.dart';


const Map <Theme,String> themeEnumToName={
  Theme.dark: "dark",
 Theme.light: "light",
  Theme.disco: 'disco',
  Theme.pinkGrey: "pinkGrey",
};


class LoggedInUserService extends GetxController {
  static LoggedInUserService get instance => Get.find();
  final UserService userService = UserService();
  final ImageStorageService imageStorageService = ImageStorageService();
  late var observableCurrency = 0.obs;
  late var observablePrestige = 0.obs;
  late var observableLevel = 0.obs;
  late var observableUsername = "".obs;
  late var observableAvatar = ''.obs;
  late var observableAchievement = [].obs;
  User? user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<String> friends = <String>[].obs;
  RxList<String> friendRequests = <String>[].obs;

  StreamSubscription<DocumentSnapshot>? _userSubscribtion;
  StreamSubscription<DocumentSnapshot>? _friendRequestSubscription;

  // Method to set user info
  void _setUser(User? user) {
    setObservable(user);
    TranslationService.instance.currentLanguage = user!.settings.language;
  }
  void setObservable(User? user){
    this.user = user;
    this.observableCurrency.value = (this.user?.currency ?? 0).round();
    this.observablePrestige.value = (this.user?.prestige ?? 0).round();
    this.observableLevel.value = (this.user?.level ?? 0).round() ~/ 10;
    this.observableUsername.value = this.user!.username;
    this.observableAvatar.value = (this.user?.avatar ?? "");
    this.observableAchievement.value = (this.user?.achievements ?? []);
  }
  Future<void> setUserByEmail(String email) async {
    User? fetchedUser = await this.userService.getUserByEmail(email); // Fetch user by email
    if (fetchedUser != null) {
      _setUser(fetchedUser); // Set the fetched user
    } else {
      print('User not found with email: $email');
    }
    _subscribeToUser();
    _subscribeToFriendRequests();
  }
  setUsername(String newUsername) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.getUid())
        .update({'username': newUsername});
    reloadUser();

  }
  Future<void> login(String email) async {
    await setUserByEmail(email);
    User? currentUser = this.user;
    if (currentUser != null) {
      if (this.user!.isConnected){
        throw("USER ALREADY CONNECTED");
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isConnected': true});
      NotificationService.instance.updateChannelMaps();
      DocumentReference userDocRef = _firestore.collection('users').doc(currentUser.uid);
      DocumentSnapshot userSnapshot = await userDocRef.get();
      List<dynamic> loginHistory = userSnapshot.get('loginHistory') ?? [];
      Timestamp timestamp = Timestamp.now(); // Get the current timestamp
      loginHistory.add({
        'eventType': 'login',
        'timestamp': timestamp,
      });
      userDocRef.update({'loginHistory': loginHistory});
      reloadUser();
      LanguageService.instance.loadLanguage();
      Theme? l = this.user?.settings.theme!;
      String themeName = themeEnumToName[l]!;
      ThemeService.instance.setTheme(themeName);
      StoreService.instance.setup();
      UserPageCustomisationService.instance.subscribeToStoreAccount();
    } else {
      print('Login failed: user not found with email $email');
    }
  }

  logout() async {
    killSubscription();
    String? userId = user?.uid;  // Adjust this to match your user object structure
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    _firestore
        .collection('users')
        .doc(userId)
        .update({'isConnected': false});

    if (userSnapshot.exists) {
      List<dynamic> loginHistory = userSnapshot.get('loginHistory') ?? [];
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());
      loginHistory.add({
        'eventType': 'logout',
        'timestamp': timestamp,
      });
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'loginHistory': loginHistory,
      });
      print('Logout event added successfully');
    } else {
      print('User not found.');
    }
    this.user =null;
    this.killSubscription();
  }

  Future<void> reloadUser() async {
    String? uid = this.getUid();
    User? user = await UserService.instance.getUserById(uid ?? '');
    this._setUser(user);
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
    File? image = await CameraService().takePhoto();
    String? newImagelLink = await this.imageStorageService.uploadImage(image!);
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

Future<void> killSubscription() async {
  await _userSubscribtion?.cancel();
  await _friendRequestSubscription?.cancel();
  print("cancelled subsrciption");
}

  @override
  void onClose() {
    _userSubscribtion?.cancel();
    _friendRequestSubscription?.cancel();
    super.onClose();
  }

  Future<void> _subscribeToUser() async {
    String? userId = LoggedInUserService.instance.getUid();
    if (userId == null) return;
    await _userSubscribtion?.cancel();

    _userSubscribtion = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      print("userSubscription called");

      if (snapshot.exists) {
        User user = User.fromJson(snapshot.data()!);
        setObservable(user);
        List<dynamic> friendsList = snapshot['friends'] ?? [];
        friends.assignAll(friendsList.map((friend) => friend.toString()).toList());
      }
    }, onError: (e) {
      print('Error listening to friends: $e');
    });
  }

  Future<void> _subscribeToFriendRequests() async {
    String? currentUserId = LoggedInUserService.instance.getUid();
    if (currentUserId == null) return;
    await _friendRequestSubscription?.cancel();
    _friendRequestSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .listen((snapshot) {
          print("freindRequestSubscription called");
      if (snapshot.exists) {
        List<dynamic> friendRequestsList = snapshot['friendRequests'] ?? [];
        List<String> pendingRequests = friendRequestsList.map<String>((request) {
          if (request is Map<String, dynamic>) {
            String userId;
            if (request['fromUserId'] == currentUserId) {
              userId = request['toUserId'] as String;
            } else {
              userId = request['fromUserId'] as String;
            }
            return userId;
          }
          return '';
        }).where((id) => id.isNotEmpty).toList();
        friendRequests.assignAll(pendingRequests);
      }
    }, onError: (e) {
      print('Error listening to friend requests: $e');
    });
  }

}