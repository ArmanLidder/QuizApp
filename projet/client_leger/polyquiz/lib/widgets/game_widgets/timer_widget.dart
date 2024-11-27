import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/theme_service.dart';
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
  ThemeService themeService = ThemeService.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //NE PAS DELETE LA LIGNE EN BAS JE SAIS QUE TON IDE TE DIS QUE C'EST PAS UTILISÉ
      // MAIS IL VOIT PAS QUE OBX LE SCRUTE!!!! (il y a qqn qui delete ces fonctions)
      //-MAXIME
      var observationEnablerDONOTDELETE = TranslationService.instance.languageValue.value;

      return Container(
      margin: EdgeInsets.all(5.0),
      height: 210,
      width: 220,
      decoration: BoxDecoration(
          border: Border.all(color: themeService.mainAccent.value),
          borderRadius: BorderRadius.circular(100.0)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${widget.timeTxt}',
              style:
              TextStyle(fontSize: 20, color: themeService.mainAccent.value),
            ),
            Text(
              '${widget.time}',
              style:
              TextStyle(fontSize: 28, color: themeService.mainAccent.value),
            ),
            Visibility(
              visible: widget.isHost,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    color: themeService.mainAccent.value,
                    onPressed: () {
                      if (widget.hostInterfaceManagementService != null) {
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
                    color: themeService.mainAccent.value,
                    onPressed: () {
                      if (widget.hostInterfaceManagementService != null) {
                        if (widget.hostInterfaceManagementService?.gameService
                            ?.isPanicDisabled() ==
                            false) {
                          widget.hostInterfaceManagementService?.startPanicMode();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(gameText['TOOLTIP']
                              ['TOOLTIP_PANIC_MODE_DISABLED']),
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
    });
  }
}

IconData changeIcon(IconData timerIcon) {
  timerIcon = timerIcon == Icons.pause_circle_outline
      ? Icons.play_circle_outline
      : Icons.pause_circle_outline;
  return timerIcon;
}
