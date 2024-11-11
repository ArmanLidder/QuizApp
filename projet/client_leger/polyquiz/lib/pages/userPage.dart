import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/user_widget/FriendListWidget.dart';
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
  User? userData;

  @override
  Widget build(BuildContext context) {
    print(this.userData);
    this.userData = this.loggedInUserService.getUser();
    print(this.userData);
    List<num> achievements = this.userData?.achievements ?? [];

    return MaterialApp(
      home: Scaffold(        backgroundColor: themeService.mixedMain,

        appBar: FancyAppBar(
            context: context,
            ),
        body: Center(
        child: Padding(
        padding: const EdgeInsets.only(top: 10.0), // Shift down by 10px
          child:FractionallySizedBox(
            widthFactor: 0.8,
              child: Container(
                decoration: BoxDecoration(
                  color: themeService.mainBackground.value, // Set the background color here
                  borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                ),
                child: SingleChildScrollView(
                  child: Column(children: [
                    ProfileCard(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          StatitisticsBlorb(
                            nPlayedGames: userData?.stats.gamesPlayed ?? 0,
                            nWonGames: userData?.stats.gamesWon ?? 0,
                            avgGoodAnswers: userData?.stats.avgCorrectAnswers ?? 0,
                            avgGameTime: userData?.stats.avgGameTime ?? 0,
                          ),

                          FriendListDisplay(friends: userData?.friends ?? [],
                              pendingRequests: userData?.friendRequests ?? []),

                          StarCardGrid(
                              achievementsList: achievements),

                          Historique(
                            gameHistory: userData?.gameHistory ?? [],
                            loginHistory: userData?.loginHistory ?? [],
                          ),

                        ],

                      ),
                    )
                  ],),)
              ),
            )
          )
        )
      )
    );
  }
}
