import 'package:flutter/material.dart';
import 'pages/login-page.dart';
import 'pages/auth_screen.dart';
import 'pages/room_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyquiz',
      initialRoute: '/',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/': (context) => LoginPage(),
        '/room': (context) => RoomListPage(),
      },
    );
  }
}

