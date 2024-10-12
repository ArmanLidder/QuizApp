import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final bool isHost;

  const TimerWidget({
    Key? key,
    required this.isHost,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Time left: '),
        Text('10'),
        widget.isHost == true
            ? IconButton(
                onPressed: () => {}, icon: Icon(Icons.pause_circle_outline))
            : SizedBox.shrink() // abscence de widget
      ],
    );
  }
}
