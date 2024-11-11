import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/user.dart';
import '../widgets/user_widget/fancyAppBar.dart';

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
      appBar: FancyAppBar(
        context: context,
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Bienvenue " +this.loggedInUserService.getUser()!.username + " !",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)) ,
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/join');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
                child: Text('Joindre une partie'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/quizz');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
              ),
              child: Text('Créer une partie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/offline');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Jouer hors-ligne')),
            const SizedBox(height: 20),
            /*ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/user');
                },
                child: Text("user page")),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/store');
                },
                child: Text("store")),*/

            ChatPopup(),
          ],
        ),
      ),
    );
  }
}
