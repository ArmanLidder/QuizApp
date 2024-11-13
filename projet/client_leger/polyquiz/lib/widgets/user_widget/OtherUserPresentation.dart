import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';

import '../../models/user.dart';
import '../../services/user_service.dart';
import 'AchievmentColumn.dart';

class OtherUserPresentation extends StatelessWidget {
  final String userId;
  final UserService userService = UserService.instance;

  OtherUserPresentation({required this.userId});

  Future<Map<String, dynamic>> _fetchUserData() async {
    // Fetch user data from your user service or Firestore based on userId
    final User? userDoc = await userService.getUserById(userId);
    return {
      "avatarUrl": userDoc?.avatar,
      "username": userDoc?.username,
      "level": userDoc?.level,
      "prestige": userDoc?.prestige,
      "currency": userDoc?.currency,
      "gamesPlayed": userDoc?.stats.gamesPlayed,
      "gamesWon": userDoc?.stats.gamesWon,
      "correctAnswersPerGame": userDoc?.stats.avgCorrectAnswers,
      "avgTimePerGame": userDoc?.stats.avgGameTime,
      "achievements": userDoc?.achievements,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text("Error loading user data"));
        }

        // Extract the data from snapshot
        final data = snapshot.data!;
        final avatarUrl = data['avatarUrl'];
        final username = data['username'];
        final level = data['level'];
        final prestige = data['prestige'];
        final currency = data['currency'];
        final gamesPlayed = data['gamesPlayed'];
        final gamesWon = data['gamesWon'];
        final correctAnswersPerGame = data['correctAnswersPerGame'];
        final avgTimePerGame = data['avgTimePerGame'];
        final achievements = data['achievements'];

        // Build the UI using the fetched data
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(child:


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar, username, and level
                Row(
                  children: [SmartAvatar(userId: userId,size: 60),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Prestige: $prestige'),
                        Text('Currency: $currency'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Game stats
                Text('Parties Jouées: $gamesPlayed'),
                Text('Parties Gagnées: $gamesWon'),
                Text('Bonnes réponses par partie: $correctAnswersPerGame'),
                Text('Temps moyen par partie: ${avgTimePerGame}s'),
                SizedBox(height: 16),
                Text('Exploits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                AchievementColumn(completedAchievements: [0,2,3]),
              ],
            ),),
          ),
        );
      },
    );
  }
}




