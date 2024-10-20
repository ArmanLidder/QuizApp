import 'package:flutter/material.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'pages/login-page.dart';
import 'pages/auth_screen.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // await dotenv.load(fileName: ".env");
  runApp(MyApp());
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
        '/auth': (context) => AuthScreen(),
        '/': (context) => LoginPage(),
        '/quizz': (context) => QuizListPage(),
        '/join': (context) => JoinRoomPage(),
        '/game': (context) => GamePage()
      },
    );
  }
}
