import 'package:flutter/material.dart';

class MessageWindow extends StatefulWidget {
  @override
  _MessageWindowState createState() => _MessageWindowState();
}

class _MessageWindowState extends State<MessageWindow> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  bool _isOpen = false;

  Future<void> openChat(BuildContext context) {
    setState(() {
      _isOpen = true;
    });
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              height: 500,
              width: 500,
              child: buildChat(),
            ),
          );
        }
    );
  }

  void closeChat() {
    setState(() {
      _isOpen = false;
    });
  }

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
    return buildPopupButton(context);
  }

  Widget buildMessageContainer() {
    return Container(
        padding: EdgeInsets.all(30.0),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return buildSingleMessage(message, "me");
                }
                )
        )
    );
  }

  Widget buildSingleMessage(String content, String author) {
    return Container(
        padding: EdgeInsets.all(18.0),
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.0)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$author:",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                  // Il faudrait avoir un espace
                  Text(content,
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                ])));
  }

  Widget buildInputBox() {
    return Container(
      padding: EdgeInsets.all(30.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 2.0,
            ),
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12.0),
        ),
            child: Container(
                padding: EdgeInsets.all(12.0),
                child:
    Row(children: <Widget>[
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
    ]))));
  }

  Widget buildPopupButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        onPressed: () {
          if (_isOpen) {
            openChat(context);
          }
        },
        child: Icon(Icons.message),
      )
    );
  }

  Widget buildChat() {
    return Container(
        child: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Zone de Clavardage",
                style: TextStyle(
                  fontSize: 24.0,
                ),
                textAlign: TextAlign.center,
              )),
          // Cette section est la liste des messages déjà envoyés
          Expanded(child: buildMessageContainer()),
          buildInputBox(),
        ]));
  }
}
