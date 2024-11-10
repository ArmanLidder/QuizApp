import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/widgets/user_widget/FriendListWidget.dart';
import '../widgets/user_widget/fancyAppBar.dart';
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
  User? userData;

  @override
  Widget build(BuildContext context) {
    print(this.userData);
    this.userData = this.loggedInUserService.getUser();
    print(this.userData);
    List<num> achievements = this.userData?.achievements ?? [];

    return MaterialApp(
      home: Scaffold(
        appBar: FancyAppBar(
            context: context,
            sourceImgUrl: this.userData?.avatar ?? "", name: this.userData?.username ?? ""),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProfileCard(
              ),
              StatitisticsBlorb(
                nPlayedGames: userData?.stats.gamesPlayed ?? 0,
                nWonGames: userData?.stats.gamesWon ?? 0,
                avgGoodAnswers: userData?.stats.avgCorrectAnswers ?? 0,
                avgGameTime: userData?.stats.avgGameTime ?? 0,
              ),
              Text(
            "Accomplissements",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
            )),
              StarCardGrid(
                  labels:
                  List.generate(8, (index) => "Defi numero ${index + 1}"),
                  achievementsList: achievements),
              Text(
                  "Amis",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),

              FriendListDisplay(friends: userData?.friends ?? [],
                  pendingRequests: userData?.friendRequests ?? []),

              Historique(
                gameHistory: userData?.gameHistory ?? [],
                loginHistory: userData?.loginHistory ?? [],
              ),

            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text("Retours a la page d'origine"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
