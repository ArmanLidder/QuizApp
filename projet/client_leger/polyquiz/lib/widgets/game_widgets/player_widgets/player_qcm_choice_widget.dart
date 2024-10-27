import 'package:flutter/material.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';

class PlayerQcmChoice extends StatefulWidget {
  final int index;
  final String choice;
  final GameInterfaceManagementService? gameInterfaceManagementService;

  const PlayerQcmChoice({
    Key? key,
    required this.index,
    required this.choice,
    this.gameInterfaceManagementService,
  }) : super(key: key);

  @override
  State<PlayerQcmChoice> createState() => _PlayerQcmChoiceWidgetState();
}

class _PlayerQcmChoiceWidgetState extends State<PlayerQcmChoice> {
  late int lastQuestionIndex;

  @override
  void initState() {
    super.initState();
    lastQuestionIndex = widget.gameInterfaceManagementService!.gameService.questionNumber;
  }

  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    if(lastQuestionIndex != widget.gameInterfaceManagementService!.gameService.questionNumber && textBtnColor == Color.fromRGBO(53, 121, 246, 1)){
      
      textBtnColor = Color.fromRGBO(0, 0, 0, 0);
      lastQuestionIndex = widget.gameInterfaceManagementService!.gameService.questionNumber;
    }
    return TextButton(
      onPressed: () {
        setState(() {
          textBtnColor = changeColor(textBtnColor);
          widget.gameInterfaceManagementService!.gameService.selectChoice(widget.index);
        });
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
          '${widget.index + 1}. ${widget.choice}',
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
