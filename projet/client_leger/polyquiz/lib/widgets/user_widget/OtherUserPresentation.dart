import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import 'AchievmentColumn.dart';
import 'package:polyquiz/widgets/user_widget/friend/smartFriendIcon.dart';

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
        final username = data['username'];
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
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5, // 80% of screen width
        height: MediaQuery.of(context).size.height * 0.8, // 70% of screen height
        child:

          Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar, username, and level
                Stack(
                  children: [
                    Row(
                      children: [
                        SmartAvatar(userId: userId, size: 60, interactible: false,),
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
                    Positioned(
                      top: 0,
                      right: 0,
                      child: SmartFriendIcon(targetUserId: userId),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Game stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parties Jouées:'),
                    Text('$gamesPlayed', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parties Gagnées:'),
                    Text('$gamesWon', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Bonnes réponses par partie:'),
                    Text('$correctAnswersPerGame', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Temps moyen par partie:'),
                    Text('${avgTimePerGame}s', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),                SizedBox(height: 16),
                Text('Exploits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                AchievementColumn(completedAchievements: achievements),
              ],
            ),),
          ),
        ));
      },
    );
  }
}




