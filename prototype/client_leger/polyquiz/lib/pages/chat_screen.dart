import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SocketService _socketService;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    _socketService = SocketService();
    _socketService.connect(token);

    print('Token from SharedPreferences: $token');
    print('see the socket:');
    if (token.isNotEmpty) {
      _socketService.on('allMessages', (data) {
        print('Received allMessages event: $data');
        setState(() {
          _messages.clear();
          _messages.addAll(List<Map<String, dynamic>>.from(data));
        });
      });

      _socketService.on('message', (data) {
        print('Received message event: $data');
        setState(() {
          _messages.add(Map<String, dynamic>.from(data));
        });
      });
    } else {
      print('No token found in SharedPreferences');
    }
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      print('Sending message: $message');
      _socketService.sendMessage('chatMessage', message);
      _messageController.clear();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Remove token from SharedPreferences
    _socketService.disconnect();  // Disconnect the socket

    // Navigate back to login screen or another screen after logout
    Navigator.pushReplacementNamed(context, '/auth');
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,  // Call the logout function
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['user'] ?? 'Unknown'),
                  subtitle: Text(message['text']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
