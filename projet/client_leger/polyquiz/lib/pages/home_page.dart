import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/services/socket_service.dart';


class HomePage extends StatelessWidget {
  final SocketService _socketService = SocketService(); 

  @override
  void initState() {
    if(_socketService.isSocketAlive()) {
      _socketService.disconnect();
      _socketService.clearAllListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height:20),
            ElevatedButton(onPressed: () {
              Navigator.pushReplacementNamed(context, '/user');
            }, child: Text("user page")
            ),
            ChatPopup(),
          ],
        ),
      ),
    );
  }
}