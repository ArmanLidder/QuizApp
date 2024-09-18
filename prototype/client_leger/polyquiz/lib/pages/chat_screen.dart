// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for formatting dates
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
    print('verify last time token: $token');

    // if (_socketService.socket.connected) {
    //     _socketService.disconnect();
    // }

    // Connect with the new token
    _socketService = SocketService();
    _socketService.connect(token);
    if (token.isNotEmpty) {
      _socketService.on('allMessages', (data) {
        if (mounted) {
          print('Fetched messages after login');
          setState(() {
            _messages.clear();
            _messages.addAll(List<Map<String, dynamic>>.from(data));
          });
        }
      });

      _socketService.on('message', (data) {
        setState(() {
          _messages.add(Map<String, dynamic>.from(data));
        });
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      _socketService.sendMessage('chatMessage', message);
      _messageController.clear();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _socketService.disconnect();

    Navigator.pushReplacementNamed(context, '/auth');
    print(_socketService.socket.id);
  }

  // @override
  // void dispose() {
  //   _socketService.disconnect();
  //   _messageController.dispose();
  //   super.dispose();
  // }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime parsedDate = DateTime.parse(timestamp);
      return DateFormat('HH:mm:ss').format(parsedDate);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
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
                final formattedTime = _formatTimestamp(message['createdAt'] ?? '');

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message['user'] ?? 'Unknown',
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          Text(
                            formattedTime,
                            style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(message['text']),
                      Divider(),
                    ],
                  ),
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
