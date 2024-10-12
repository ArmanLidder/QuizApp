import 'package:flutter/material.dart';
import 'pages/login-page.dart';
import 'pages/auth_screen.dart';
import 'pages/quiz_list_page.dart';

void main() {
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
      },
    );
  }
}

