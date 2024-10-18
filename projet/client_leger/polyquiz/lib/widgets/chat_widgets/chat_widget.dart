import 'package:flutter/material.dart';

class ChatWidget extends StatefulWidget {
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Expanded(
            child: Container(
                color: Colors.blue,
                child: Row(
                  children: [
                    Icon(Icons.textsms, size: 40),
                    Text("Clavardage", style: TextStyle(fontSize: 40)),
                  ],
                )
            ),
          ),
          Expanded(
            flex: 9,
              child: Container(
                  child: Text('To be filled'),
          ))
        ]
    );
  }
}