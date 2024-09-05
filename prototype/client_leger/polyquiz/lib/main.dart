import 'package:flutter/material.dart';
import 'pages/auth_screen.dart';
import 'pages/chat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define the routes
      routes: {
        '/auth': (context) => AuthScreen(), // Define the route for authentication
        '/chat': (context) => ChatScreen(), // Define the route for chat
      },
      initialRoute: '/auth', // Set the initial route
    );
  }
}
