import 'package:flutter/material.dart';

class MessageWindow extends StatefulWidget {
  @override
  _MessageWindowState createState() => _MessageWindowState();
}

class _MessageWindowState extends State<MessageWindow> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(message);
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          // Cette section est la liste des messages déjà envoyés
          Expanded(
              child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(message)
                    );
                  }
              )
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "input a message...",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  )
                ),
                IconButton(onPressed: _sendMessage, icon: Icon(Icons.send, color: Colors.blue,))
              ]
            )
          )
        ]
      )
    );
  }
}