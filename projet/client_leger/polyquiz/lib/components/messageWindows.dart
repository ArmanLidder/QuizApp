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
    // TODO: implement build
    throw UnimplementedError();
  }
}