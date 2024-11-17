import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';

class PlayerQcmChoice extends StatefulWidget {
  final int index;
  final QuizChoice choice;

  const PlayerQcmChoice({
    Key? key,
    required this.index,
    required this.choice,
  }) : super(key: key);

  @override
  State<PlayerQcmChoice> createState() => _PlayerQcmChoiceWidgetState();
}

class _PlayerQcmChoiceWidgetState extends State<PlayerQcmChoice> {
  late int lastQuestionIndex;
  GameInterfaceManagementService gameInterfaceManagementService =
      GameInterfaceManagementService();

  @override
  void initState() {
    super.initState();
    lastQuestionIndex =
        gameInterfaceManagementService.gameService.questionNumber;
  }

  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    if (gameInterfaceManagementService.getQcmEnabled()) {
      if (lastQuestionIndex !=
              gameInterfaceManagementService.gameService.questionNumber &&
          textBtnColor != Color.fromRGBO(0, 0, 0, 0)) {
        textBtnColor = Color.fromRGBO(0, 0, 0, 0);
        lastQuestionIndex =
            gameInterfaceManagementService.gameService.questionNumber;
      } else {
        lastQuestionIndex =
            gameInterfaceManagementService.gameService.questionNumber;
      }
    } else {
      textBtnColor = widget.choice.isCorrect!
          ? Color.fromRGBO(123, 229, 117, 1)
          : Color.fromRGBO(246, 53, 53, 1);
    }
    return TextButton(
      onPressed: () {
        if (!this.gameInterfaceManagementService.gameService.realGameService.isHostEvaluating &&
            this.gameInterfaceManagementService.gameService.realGameService.isValidateActive){
              gameInterfaceManagementService.getQcmEnabled()
                  ? setState(() {
                      textBtnColor = changeColor(textBtnColor);
                      if (gameInterfaceManagementService.gameService.isOfflineMode) {
                        gameInterfaceManagementService.gameService
                            .selectChoiceOffline(widget.index);
                      } else {
                        gameInterfaceManagementService.gameService
                            .selectChoice(widget.index);
                      }
                    })
                  : () {};
            }
      },
      style: TextButton.styleFrom(
          side: BorderSide(color: Color.fromRGBO(0, 0, 0, 1)),
          textStyle: TextStyle(fontWeight: FontWeight.normal),
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: textBtnColor),
      child: Center(
        child: Text(
          '${widget.index + 1}. ${widget.choice.text}',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}

Color changeColor(Color textBtnColor) {
  textBtnColor = textBtnColor == Color.fromRGBO(0, 0, 0, 0)
      ? Color.fromRGBO(53, 121, 246, 1)
      : Color.fromRGBO(0, 0, 0, 0);
  return textBtnColor;
}
