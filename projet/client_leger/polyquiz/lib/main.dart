import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/pages/game_page.dart';
import 'package:polyquiz/pages/offline_game_page.dart';
import 'package:polyquiz/pages/offline_quiz_list_page.dart';
import 'package:polyquiz/pages/waiting_room_screen.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/userInfoValidation.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/background_notification_service.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/notification_service.dart';
import 'pages/authPage.dart';
import 'pages/quiz_list_page.dart';
import 'pages/join_room_page.dart';
import 'pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/pages/userPage.dart';
import 'package:polyquiz/pages/storePage.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/game_list_item.dart';
import 'package:polyquiz/pages/active_game_list.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/room_validation_service.dart';
import 'package:polyquiz/services/snack_bar_service.dart';

final socketService = SocketService();
final userService = UserService();
final quizService = QuizService();
final snackbarService = SnackbarService();
// final roomValidationService = RoomValidationService(socketService: socketService);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(LoggedInUserService());
  Get.put(ChannelService());
  Get.put(UserService());
  Get.put(ImageStorageService());
  Get.put(NotificationService());
  Get.put(BackgroundNotificationService());
  Get.put(StoreService());
  Get.put(UserPageCustomisationService());
  Get.put(ThemeService());
  Get.put(FriendService());
  Get.put(ValidationService());
  Get.put(TranslationService());
  Get.put(LanguageService());

  FriendService.instance.onInit();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameConfigService()),
        ChangeNotifierProvider(
            create: (_) => GameListService(socketService: socketService)),
        ChangeNotifierProvider(
            create: (_) => RoomValidationService(socketService: socketService)),
        Provider(create: (_) => socketService),
        Provider(create: (_) => userService),
        Provider(create: (_) => quizService),
        Provider(create: (_) => snackbarService),
        // Provider(create: (_) => roomValidationService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyquiz',
      navigatorKey: GlobalNavigationService.navigatorKey,
      home: PopScope(
        canPop: false,
        child: AuthPage(),
      ),
      routes: {
        '/home': (context) => PopScope(
              canPop: false,
              child: HomePage(),
            ),
        '/auth': (context) => PopScope(
              canPop: false,
              child: AuthPage(),
            ),
        '/quizz': (context) => PopScope(
              canPop: false,
              child: QuizListPage(),
            ),
        '/offline': (context) => PopScope(
              canPop: false,
              child: OfflineQuizListPage(),
            ),
        '/offlinegame': (context) => PopScope(
              canPop: false,
              child: OfflineGamePage(),
            ),
        '/join': (context) => PopScope(
              canPop: false,
              child: JoinRoomPage(),
            ),
        '/roomList': (context) => PopScope(
              canPop: false,
              child: ActiveGameListComponent(),
            ),
        '/game': (context) => PopScope(
              canPop: false,
              child: GamePage(),
            ),
        '/user': (context) => PopScope(
              canPop: false,
              child: Userpage(),
            ),
        '/store': (context) => PopScope(
              canPop: false,
              child: Storepage(),
            ),
        '/waitingRoom': (context) => PopScope(
              canPop: false,
              child: WaitingRoomScreen(
                quiz: ModalRoute.of(context)!.settings.arguments as Quiz,
                isHost: true,
              ),
            ),
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'Polyquiz',
  //     navigatorKey: GlobalNavigationService.navigatorKey,
  //     home: AuthPage(), // The starting page is set to LoginPage.
  //     routes: {
  //       '/home': (context) => HomePage(),
  //       '/auth': (context) => AuthPage(),
  //       '/quizz': (context) => QuizListPage(),
  //       '/offline': (context) => OfflineQuizListPage(),
  //       '/offlinegame': (context) => OfflineGamePage(),
  //       '/join': (context) => JoinRoomPage(),
  //       '/roomList': (context) => ActiveGameListComponent(),
  //       '/game': (context) => GamePage(),
  //       '/user': (context) => Userpage(),
  //       '/store': (context) => Storepage(),
  //       '/waitingRoom': (context) => WaitingRoomScreen(
  //           quiz: ModalRoute.of(context)!.settings.arguments as Quiz,
  //           isHost: true),
  //     },
  //   );
  // }
}
