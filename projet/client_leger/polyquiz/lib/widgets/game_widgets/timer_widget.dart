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
  IconData panicModeIcon =
      Icons.fireplace_outlined; // Changer pour coherence avec client lourd
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
            'Temps restant: ',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            '${widget.time}',
            style: TextStyle(fontSize: 28),
          ),
          Visibility(
            visible: widget.isHost,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      timerIcon = changeIcon(timerIcon);
                    });
                  },
                  icon: Icon(timerIcon),
                  iconSize: 35,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(panicModeIcon),
                  iconSize: 35,
                )
              ],
            ),
          )
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
