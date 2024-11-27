import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/user_widget/friend/FriendListWidget.dart';
import '../widgets/fancyAppBar.dart';
import '../widgets/user_widget/ProfileCard.dart';
import '../widgets/user_widget/statisticBlorb.dart';
import '../widgets/user_widget/starComponent.dart';
import '../widgets/user_widget/historique.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class Userpage extends StatelessWidget {
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();
  final ThemeService themeService = ThemeService.instance;
  final TranslationService transService = TranslationService.instance;
  User? userData;

  @override
  Widget build(BuildContext context) {
    print(this.userData);
    this.userData = this.loggedInUserService.getUser();
    print(this.userData);

    return Obx(() {
      Language uselessShit = transService.languageValue.value;
      return MaterialApp(
        home: Scaffold(
          backgroundColor: themeService.mainBackground.value,
          appBar: FancyAppBar(
            context: context,
            canLeaveFromAppBar: true,
          ),
          body: Stack(
            children: [
              // Centered FractionallySizedBox with scrollable content
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0), // Shift down by 10px
                  child: FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Container(
                      color: themeService.mainBackground
                          .value, // Set the background color here
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ProfileCard(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  StatitisticsBlorb(
                                    nPlayedGames:
                                        userData?.stats.gamesPlayed ?? 0,
                                    nWonGames: userData?.stats.gamesWon ?? 0,
                                    avgGoodAnswers:
                                        userData?.stats.avgCorrectAnswers ?? 0,
                                    avgGameTime:
                                        userData?.stats.avgGameTime ?? 0,
                                  ),
                                  FriendListDisplay(),
                                  StarCardGrid(),
                                  Historique(
                                    gameHistory: userData?.gameHistory ?? [],
                                    loginHistory: userData?.loginHistory ?? [],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned text at the bottom-right corner of the screen
              Positioned(
                  bottom: 20.0, // Adjust the position from the bottom
                  left: 20.0, // Adjust the position from the right
                  child: ChatPopup()),
            ],
          ),
        ),
      );
    });
  }
}
