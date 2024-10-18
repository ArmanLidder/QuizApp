import 'package:flutter/material.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
// import 'package:polyquiz/pages/game_page.dart';
import 'pages/login-page.dart';
import 'pages/auth_screen.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';

void main() {
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
        '/auth': (context) => AuthScreen(),
        '/': (context) => LoginPage(),
        '/quizz': (context) => QuizListPage(),
        '/join': (context) => JoinRoomPage(),
      },
    );
  }
}
