import 'package:flutter/material.dart';

class PlayerQcmChoiceWidget extends StatefulWidget {
  final int index;
  final String choice;

  const PlayerQcmChoiceWidget({
    Key? key,
    required this.index,
    required this.choice,
  }) : super(key: key);

  @override
  State<PlayerQcmChoiceWidget> createState() => _PlayerQcmChoiceWidgetState();
}

class _PlayerQcmChoiceWidgetState extends State<PlayerQcmChoiceWidget> {
  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          textBtnColor = changeColor(textBtnColor);
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
