import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/cancel_btn.dart';
import '../models/quiz.dart';
import 'waiting_room_screen.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/models/user.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({Key? key}) : super(key: key);

  @override
  _JoinRoomPageState createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _usernameController = TextEditingController();
  final _roomIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isJoining = false;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;

  @override
  void dispose() {
    _usernameController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      final roomId = _roomIdController.text.trim();
      this.userData = this.loggedInUserService.getUser();

      setState(() {
        _isJoining = true;
      });

      try {
        // Navigate to the WaitingRoomScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingRoomScreen(
              quiz: Quiz(
                id: roomId, // Pass the room ID to the waiting room.
                title: 'Nothing', // Provide a sample title.
                description: 'Nothing', // Provide a sample description.
                duration: 0, // Provide a sample duration.
                questions: [], // Provide an empty list of questions.
              ),
              username:
                  this.userData!.uid, // Pass the username to the waiting room.
              isHost: false, // This user is not the host.
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isJoining = false;
        });

        // Display an error message if joining fails.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join a Room'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/roomList');
              },
              child: Text(
                "Rejoindre Jeu Public",
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(53, 121, 246, 1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Veuillez saisir le code de 4 chiffre fourni par l'organisateur",
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _roomIdController,
                    decoration: InputDecoration(
                      labelText: 'Saisir le code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a Room ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  _isJoining
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: _joinRoom,
                                child: Text('Valider',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20)),
                                style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(53, 121, 246, 1))),
                            CancelBtn()
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
