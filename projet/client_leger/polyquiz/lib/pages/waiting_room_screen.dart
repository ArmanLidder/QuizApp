import 'package:flutter/material.dart';
import '../services/waiting_room_service.dart'; // Service to manage waiting room logic
import '../models/quiz.dart';

class WaitingRoomScreen extends StatefulWidget {
  final Quiz quiz;

  const WaitingRoomScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _WaitingRoomScreenState createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  List<String> players = []; // List to store player names
  String roomId = ""; // Room ID
  bool isRoomLocked = false; // Lock status

  @override
  void initState() {
    super.initState();
    _initRoom();
  }

  Future<void> _initRoom() async {
    // Initialize the room with a unique ID
    roomId = await WaitingRoomService.createRoom(widget.quiz.id);
    setState(() {});
  }

  void _toggleRoomLock() {
    setState(() {
      isRoomLocked = !isRoomLocked;
    });
    // Optionally, update the lock status in the server
    WaitingRoomService.updateRoomLockStatus(roomId, isRoomLocked);
  }

  void _startGame() {
    // Start the game logic here
    // Navigate to the quiz screen or start the quiz
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waiting Room')),
      body: Column(
        children: [
          Text('Room ID: $roomId'),
          SwitchListTile(
            title: Text('Lock Room'),
            value: isRoomLocked,
            onChanged: (bool value) => _toggleRoomLock(),
          ),
          Text('Players:'),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(players[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      // Optionally remove player
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _startGame,
            child: Text('Start Game'),
          ),
        ],
      ),
    );
  }
}
