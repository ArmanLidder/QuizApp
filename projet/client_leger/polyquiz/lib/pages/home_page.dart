import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
import '../widgets/fancyAppBar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ThemeService themeService = ThemeService.instance;

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
    return Scaffold(
      backgroundColor: this.themeService.mainBackground.value,  // Set background color
      appBar: FancyAppBar(
        context: context,
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Bienvenue " +this.loggedInUserService.getUser()!.username + " !",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: this.themeService.mainAccent.value),
                  ) ,
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/join');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: this.themeService.secondaryBackground.value,
                foregroundColor: this.themeService.secondaryAccent.value,
              ),
                child: Text('Joindre une partie'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/quizz');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: this.themeService.secondaryBackground.value,
                  foregroundColor: this.themeService.secondaryAccent.value,
              ),
              child: Text('Créer une partie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/offline');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: this.themeService.secondaryBackground.value,
                  foregroundColor: this.themeService.secondaryAccent.value,
                ),
                child: Text('Jouer hors-ligne')),
            const SizedBox(height: 20),

            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/store');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: this.themeService.secondaryBackground.value,
                  foregroundColor: this.themeService.secondaryAccent.value,
                ),
                child: Text('Magasin')),
            SmartAvatar(userId: loggedInUserService.getUid()!, size:100, hasName: true),
            ChatPopup(),
          ],
        ),
      ),
    );
  }
}
