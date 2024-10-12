import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/timer_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GamePage> {
  bool isHost = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolyQuiz'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(53, 121, 246, 1),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [TimerWidget(isHost: isHost)],
            )
          ],
        ),
      ),
    );
  }
}
