import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polyquiz/pages/token_manager.dart';
import 'socket_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _socketService = SocketService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  TokenSingleton t_storage = TokenSingleton.instance;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    String? token = t_storage.token;
    if (token == null) print("GARAGE");
    else _socketService.connect(token);
    if (_socketService.socket != null) {
      _socketService.on('allMessages', (data) {
          setState(() {
            _messages.clear();
            _messages.addAll(List<Map<String, dynamic>>.from(data));
          });
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 100); // The offset is added since the newest message is hidden by the chat box
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

  void _logout() {
    _socketService.disconnect();
    t_storage.clearToken();
    Navigator.pushReplacementNamed(context, '/auth');
  }

  String _formatTimestamp(String timestamp) {
    try {
      tz.initializeTimeZones();
      final montreal = tz.getLocation('America/Montreal');
      DateTime parsedDate = DateTime.parse(timestamp);
      final montrealTime = tz.TZDateTime.from(parsedDate, montreal);
      return DateFormat('HH:mm:ss').format(montrealTime);
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    if(_socketService.socket != null) {
      _socketService.disconnect();
      t_storage.clearToken();
    }
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
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
