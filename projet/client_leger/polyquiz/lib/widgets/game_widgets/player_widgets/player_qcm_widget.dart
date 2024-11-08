import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_choice_widget.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/models/quiz.dart';

class PlayerQcm extends StatefulWidget {
  const PlayerQcm({super.key});

  @override
  State<PlayerQcm> createState() => _PlayerQcmWidgetState();
}

class _PlayerQcmWidgetState extends State<PlayerQcm> {
  // late List<QuizChoice> choices;
  GameInterfaceManagementService gameInterfaceManagementService =
      GameInterfaceManagementService();

  QuizQuestion? getQuestion() {
    if (gameInterfaceManagementService.qcmEnabled) {
      return gameInterfaceManagementService.gameService.question;
    } else
      return gameInterfaceManagementService.gameService.oldQuestion;
  }

  @override
  void initState() {
    super.initState();
    // choices = widget.gameInterfaceManagementService?.gameService.question?.choices ?? [];
  }

  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
            animation: gameInterfaceManagementService.gameService,
            builder: (BuildContext context, Widget? snapshot) {
              return GridView.count(
                padding: EdgeInsets.all(10.0),
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children:
                    List.generate(getQuestion()!.choices!.length, (index) {
                  return PlayerQcmChoice(
                    index: index,
                    choice: getQuestion()!.choices![index],
                  );
                }),
              );
            }));
  }
}
