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
        child: Column(children: <Widget>[
      // Cette section est la liste des messages déjà envoyés
      Expanded(
          child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return buildMessageBlock(message, "me");
              })),
      Container(
          child: Row(children: <Widget>[
        Expanded(
            child: TextField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: "input a message...",
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _sendMessage(),
        )),
        IconButton(
            onPressed: _sendMessage,
            icon: Icon(
              Icons.send,
              color: Colors.blue,
            ))
      ]))
    ]));
  }

  Widget buildMessageBlock(String content, String author) {
    return Container(
        padding: EdgeInsets.all(18.0),
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Text(
                author,
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
              // Il faudrait avoir un espace
              Text(content,
                  style: TextStyle(
                    fontSize: 16.0,
                  )),
            ])));
  }
}
