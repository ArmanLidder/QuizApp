import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/widgets/user_widget/FriendListWidget.dart';
import '../widgets/user_widget/fancyAppBar.dart';
import '../widgets/user_widget/ProfileCard.dart';
import '../widgets/user_widget/statisticBlorb.dart';
import '../widgets/user_widget/starComponent.dart';
import '../widgets/user_widget/historique.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:get/get.dart';

class Storepage extends StatelessWidget {
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;
  final StoreService storeService = Get.find();

  @override
  Widget build(BuildContext context) {

    //this.userData = this.loggedInUserService.getUser();
    void handleButtonPress() {
      String userId = "ChhstSLYrk6HloBVNM6x";
      String itemId = "u771NT8PiPk35iWsUvsc";
      storeService.buy(userId,itemId);
    }

    return MaterialApp(
      home: Scaffold(
        body: FloatingActionButton(
        onPressed: handleButtonPress,
        child: Icon(Icons.add),
      ),
      ),
    );
  }
}
