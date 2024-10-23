import 'package:flutter/material.dart';
import 'package:projet3userpage/fancyAppBar.dart';
import 'ProfileCard.dart';
import 'statisticBlorb.dart';
import 'starComponent.dart';
import 'historique.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Fetch documents from Firestore
  Map<String, dynamic>? userData =
      await fetchUserById("EIjJvAYViMPepXVvCxy3veDbcUj1");
  if (userData != null) {
    print(userData);
    runApp(MyApp(userData: userData));
  } else {
    print('User data is null');
  }
}

Future<Map<String, dynamic>?> fetchUserById(String userId) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection('users').doc(userId).get();

    // Check if the document exists
    if (snapshot.exists) {
      return snapshot.data();
    } else {
      print('No document found with ID: $userId');
      return null;
    }
  } catch (e) {
    print('Error fetching user: $e');
    return null;
  }
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> userData;
  MyApp({
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> stat = this.userData["stats"];
    List<int> achievements = List<int>.from(this.userData["achievements"]);

    return MaterialApp(
      home: Scaffold(
        appBar: FancyAppBar(
            imageUrl: this.userData["avatar"], name: this.userData["username"]),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProfileCard(
                username: this.userData["username"],
                email: this.userData["email"],
                prestige: this.userData["prestige"].toString(),
                argent: this.userData["currency"].toString(),
              ),
              StatitisticsBlorb(
                nPlayedGames: stat["gamesPlayed"],
                nWonGames: stat["gamesWon"],
                avgGoodAnswers: stat["avgCorrectAnswers"],
                avgGameTime: stat["avgGameTime"],
              ),
              StarCardGrid(
                  labels:
                      List.generate(8, (index) => "Defi numero ${index + 1}"),
                  achievementsList: achievements),
              Historique(
                events: [
                  EvenementRow(date: "2024-10-16", label: "Connection"),
                  EvenementRow(
                      date: "2024-10-17",
                      label: "Partie Gagnée",
                      color: Colors.green),
                  EvenementRow(date: "2024-10-18", label: "Déconection"),
                  EvenementRow(
                    date: "2024-10-19",
                    label: "Connection",
                  ),
                  EvenementRow(date: "2024-10-20", label: "Déconnection"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
