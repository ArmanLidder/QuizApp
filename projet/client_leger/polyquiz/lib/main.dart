import 'package:flutter/material.dart';
// import 'package:polyquiz/pages/game_page.dart';
import 'pages/login-page.dart';
import 'pages/auth_screen.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
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
