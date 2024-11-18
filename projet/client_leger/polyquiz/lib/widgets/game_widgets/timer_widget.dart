import 'package:flutter/material.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/translationService.dart';
class TimerWidget extends StatefulWidget {
  final bool isHost;
  final String timeTxt;
  final num time;
  final HostInterfaceManagementService? hostInterfaceManagementService;

  const TimerWidget({
    Key? key,
    required this.isHost,
    required this.timeTxt,
    required this.time,
    this.hostInterfaceManagementService,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  IconData timerIcon = Icons.pause_circle_outline;
  IconData panicModeIcon =
      Icons.fireplace_outlined; // Changer pour coherence avec client lourd
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get timerText => gameText['TIMER_TEXT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      height: 200,
      width: 200,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(100.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.timeTxt}',
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
                    if(widget.hostInterfaceManagementService != null ){
                      widget.hostInterfaceManagementService?.sendPauseTimer();
                      setState(() {
                        timerIcon = changeIcon(timerIcon);
                      });
                    }
                  },
                  icon: Icon(timerIcon),
                  iconSize: 35,
                ),
                IconButton(
                  onPressed: () {
                    if(widget.hostInterfaceManagementService != null ){
                      if (widget.hostInterfaceManagementService?.gameService?.isPanicDisabled() == false) {
                        widget.hostInterfaceManagementService?.startPanicMode();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(gameText['TOOLTIP']['TOOLTIP_PANIC_MODE_DISABLED']),
                          ),
                        );
                      }
                    }
                  },
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
