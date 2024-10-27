import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import '../widgets/user_widget/fancyAppBar.dart';
import '../widgets/user_widget/ProfileCard.dart';
import '../widgets/user_widget/statisticBlorb.dart';
import '../widgets/user_widget/starComponent.dart';
import '../widgets/user_widget/historique.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
//import 'package:polyquiz/models/user.dart';

class Userpage extends StatelessWidget {
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();
  User? userData = LoggedInUserService.instance.user;

  @override
  Widget build(BuildContext context) {
    print(userData);
    List<num> achievements = this.userData?.achievements ?? [];

    return MaterialApp(
      home: Scaffold(
        appBar: FancyAppBar(
            imageUrl: this.userData?.avatar ?? "", name: this.userData?.username ?? ""),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProfileCard(
                username: this.userData?.username ?? "",
                email: this.userData?.email ?? "",
                prestige: (this.userData?.prestige ?? 0).toString(),
                argent: (this.userData?.currency ?? 0).toString(),
              ),
              StatitisticsBlorb(
                nPlayedGames: userData?.stats.gamesPlayed ?? 0,
                nWonGames: userData?.stats.gamesWon ?? 0,
                avgGoodAnswers: userData?.stats.avgCorrectAnswers ?? 0,
                avgGameTime: userData?.stats.avgGameTime ?? 0,
              ),
              StarCardGrid(
                  labels:
                  List.generate(8, (index) => "Defi numero ${index + 1}"),
                  achievementsList: achievements),
              Historique(
                gameHistory: userData?.gameHistory ?? [],
                loginHistory: userData?.loginHistory ?? [],
              ),
              ElevatedButton(
                  onPressed: this.imageStorageService.pickAndUploadImage,
                  child: Text("Choisir une image TEST")
              ),

            ],
          ),
        ),
      ),
    );
  }
}
