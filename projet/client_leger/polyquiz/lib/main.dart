import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/pages/login-page.dart';
import 'package:polyquiz/pages/offline_quiz_list_page.dart';
import 'package:polyquiz/pages/waiting_room_screen.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'pages/authPage.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';
import 'pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/pages/userPage.dart';
import 'package:polyquiz/pages/storePage.dart';
import 'package:polyquiz/services/StoreService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(UserService());
  Get.put(LoggedInUserService());
  Get.put(ImageStorageService());
  Get.put(StoreService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyquiz',
      navigatorKey: GlobalNavigationService.navigatorKey,
      home: AuthPage(), // The starting page is set to LoginPage.
      routes: {
        '/home': (context) => HomePage(),
        '/auth': (context) => AuthPage(),
        '/login': (context) => LoginPage(),
        '/quizz': (context) => QuizListPage(),
        '/offline': (context) => OfflineQuizListPage(),
        '/join': (context) => JoinRoomPage(),
        '/game': (context) => GamePage(),
        '/user': (context) => Userpage(),
        '/store': (context) => Storepage(),
        '/waitingRoom': (context) => WaitingRoomScreen(
            quiz: ModalRoute.of(context)!.settings.arguments as Quiz,
            isHost: true),
      },
    );
  }
}
