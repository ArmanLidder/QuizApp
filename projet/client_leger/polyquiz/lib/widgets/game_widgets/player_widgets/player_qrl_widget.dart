import 'package:flutter/material.dart';

class PlayerQrlWidget extends StatefulWidget {
  const PlayerQrlWidget({super.key});

  @override
  State<PlayerQrlWidget> createState() => _PlayerQrlWidgetState();
}

class _PlayerQrlWidgetState extends State<PlayerQrlWidget> {
  int counter = 0;
  var inputText = '';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 100.0, 5.0, 5.0),
        child: SizedBox(
          height: 150,
          child: TextField(
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                counterText: '${inputText}/200'),
            expands: true,
            maxLines: null,
            maxLength: 200,
            onChanged: (value) {
              setState(() {
                inputText = (200 - value.characters.length).toString();
              });
            },
          ),
        ),
      ),
    );
  }
}
