import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/models/user.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final SocketService _socketService = SocketService();
  User? userData;

  @override
  void initState() {
    super.initState();
    if (_socketService.isSocketAlive()) {
      _socketService.clearAllListeners();
      _socketService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    this.userData = this.loggedInUserService.getUser();
    print(this.userData);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/join');
              },
              child: Text('Join'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/quizz');
              },
              child: Text('Quizz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/roomList');
                },
                child: Text('Rejoindre une partie')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/offline');
                },
                child: Text('Jouer hors-ligne')),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/user');
                },
                child: Text("user page")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/store');
                },
                child: Text("store")),
            ChatPopup(),
          ],
        ),
      ),
    );
  }
}
