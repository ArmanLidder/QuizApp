import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket _socket;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _socket = IO.io('http://localhost:8000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    _socket.on('connect', (_) {
      print('Connected to server');
    });

    _socket.on('allMessages', (messages) {
      setState(() {
        _messages.clear();
        _messages.addAll(List<String>.from(messages));
      });
    });

    _socket.on('message', (message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      _socket.emit('chatMessage', message);
      _messageController.clear();
    }
  }

    void _logout() async {
        print('Logout button pressed');
        if (_socket != null) {
            print('Disconnecting socket');
            await _socket.disconnect();
        }
        Navigator.pushReplacementNamed(context, '/auth');
    }

    @override
    void dispose() {
        if (_socket != null) {
            _socket.dispose();
        }
        super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Show a confirmation dialog before logging out
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: Text('Logout'),
                        onPressed: () {
                          _logout(); // Perform the logout
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_messages[index]));
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Enter message'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
