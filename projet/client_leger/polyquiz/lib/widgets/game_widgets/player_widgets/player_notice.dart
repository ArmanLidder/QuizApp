import 'package:flutter/material.dart';

class PlayerNotice extends StatelessWidget {
  final message;
  const PlayerNotice({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          '${message}',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
