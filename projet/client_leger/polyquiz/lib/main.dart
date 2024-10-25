import 'package:flutter/material.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'pages/login-page.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyquiz',
      navigatorKey: GlobalNavigationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/quizz': (context) => QuizListPage(),
        '/join': (context) => JoinRoomPage(),
        '/game': (context) => GamePage()
      },
    );
  }
}
