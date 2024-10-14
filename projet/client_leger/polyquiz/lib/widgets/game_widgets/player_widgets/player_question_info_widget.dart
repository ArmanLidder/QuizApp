import 'package:flutter/material.dart';

class PlayerQuestionInfoWidget extends StatefulWidget {
  final int questionNum;
  final int questionPts;

  const PlayerQuestionInfoWidget({
    Key? key,
    required this.questionNum,
    required this.questionPts,
  }) : super(key: key);

  @override
  State<PlayerQuestionInfoWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PlayerQuestionInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(30.0), // to center the text
      child: Column(
        children: [
          Text(
            'Q${widget.questionNum}',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.questionPts} pts',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Question question question  question?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
