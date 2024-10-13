import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final bool isHost;
  final num time;

  const TimerWidget({
    Key? key,
    required this.isHost,
    required this.time,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  IconData timerIcon = Icons.pause_circle_outline;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      height: 150,
      width: 150,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(100.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Time left: ',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            '${widget.time}',
            style: TextStyle(fontSize: 28),
          ),
          widget.isHost == true
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      timerIcon = changeIcon(timerIcon);
                    });
                  },
                  icon: Icon(timerIcon),
                  iconSize: 40,
                )
              : SizedBox.shrink() // abscence de widget
        ],
      ),
    );
  }
}

IconData changeIcon(IconData timerIcon) {
  timerIcon = timerIcon == Icons.pause_circle_outline
      ? Icons.play_circle_outline
      : Icons.pause_circle_outline;
  return timerIcon;
}
