import 'package:flutter/material.dart';
import '../models/quiz.dart';
import 'waiting_room_screen.dart';
import '../services/waiting_room_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
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
              username: this.userData!.uid, // Pass the username to the waiting room.
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              TextFormField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Enter the Room ID',
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
                  : ElevatedButton(
                      onPressed: _joinRoom,
                      child: Text('Join Room'),
                    ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text("Retours a la page d'origine"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
