import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/main.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/userInfoValidation.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/widgets/user_widget/ImageSelectionPopup.dart';
import 'package:polyquiz/widgets/user_widget/PrestigeIndicator.dart';
import 'package:polyquiz/widgets/user_widget/settings/SettingsPopup.dart';
import '../../services/imageStorageService.dart';
import '../../services/logged_in_user_service.dart';
import '../../services/theme_service.dart';
import 'changeNameWidget.dart';



class ProfileCard extends StatelessWidget {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();
  final ThemeService themeService = ThemeService.instance;
  final UserService userService = UserService.instance;
  final ValidationService validationService = ValidationService.instance;

  final UserPageCustomisationService userPageCustomisationService = UserPageCustomisationService.instance;
  final LanguageService ls = LanguageService.instance;
  Map get profileText => TranslationService.instance.text['PROFILE'];
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {  // Use Obx to listen to Rx variables
      String imageUrl = loggedInUserService.observableAvatar.value;
      final String? username = loggedInUserService.user?.username;
      final num? prestige = loggedInUserService.observablePrestige.value;
      final num? argent = loggedInUserService.observableCurrency.value;
      Future<void> _imageChangeButton() async {
        await loggedInUserService.uploadCustomProfilePicture();
      }


      Future<void> _showImageSelectionPopup() async {
        String? uid = loggedInUserService.getUid();
        List<String> imageUrls = await userPageCustomisationService.availableImages(uid!) as List<String>;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ImageSelectionPopup(
              imageUrls: imageUrls,
              onPlusButtonPressed: _imageChangeButton,
            );
          },
        );

        return Future.value(); // Returning a completed Future
      }

      loggedInUserService.reloadUser();
      return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: themeService.mainBackground.value, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 106,
                            right: 106,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: themeService.mainBackground.value, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  loggedInUserService.getUser()!.level.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: themeService.mainAccent.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSelectionPopup,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: themeService.mainBackground.value,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: themeService.secondaryBackground.value,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loggedInUserService.observableUsername.value,
                            style: TextStyle(
                              color: themeService.mainBackground.value,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8), // Add some spacing between the text and the icon
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ChangeNamePopup(
                                    initialUsername: username!,
                                  );
                                },
                              );
                            },                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: themeService.mainBackground.value,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.edit,
                                  color: themeService.secondaryBackground.value,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        loggedInUserService.getUser()!.email,
                        style: TextStyle(
                          color: themeService.mainBackground.value,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          PrestigeIndicator(prestige: prestige),
                          Chip(
                            label: Text(
                              profileText['CURRENCY'] + ": "+  argent.toString(),
                              style: TextStyle(color: themeService.mainAccent.value),
                            ),
                            backgroundColor: themeService.mainBackground.value.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: themeService.mainBackground.value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

}
