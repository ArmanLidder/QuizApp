import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart' as Quiz;
import 'package:polyquiz/services/game_interface_management_service.dart';

class PlayerQreWidget extends StatefulWidget {
  const PlayerQreWidget({super.key});

  @override
  State<PlayerQreWidget> createState() => _PlayerQreWidgetState();
}

class _PlayerQreWidgetState extends State<PlayerQreWidget> {
  GameInterfaceManagementService gameInterfaceManagementService = GameInterfaceManagementService();
  int currentValue = 0;

  @override
  void initState() {
    super.initState();
    if (question != null && question?.interval != null) {
      final max = question!.interval!.max;
      final min = question!.interval!.min;
      currentValue = ((max + min) / 2).round();
    }
  }

  Quiz.QuizQuestion get defaultQuestion {
    return Quiz.QuizQuestion(
        type: QuestionType.QRE,
        text: "Mount Everest Height? (meters)",
        points: 40,
        answer: 8849,
        interval: Quiz.Interval(max: 9000, min: 8800),
        margin: 10,
        imageUrl: "https://firebasestorage.googleapis.com/v0/b/polyquiz-app.appspot.com/o/quizImages%2F1730682720280.png?alt=media&token=3e58c73f-8803-4bba-907c-72981d7c516e",
    );
  }

  Quiz.QuizQuestion? get question {
    // return gameInterfaceManagementService.gameService.question;
    return defaultQuestion;
  }

  num get max {
    return question?.interval?.max ?? 1;
  }

  num get min {
    return question?.interval?.min ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          getSlider(),
        ],
      ),
    );
  }

  Widget getSlider() {
    return Slider(
      value: currentValue.toDouble(),
      max: this.max.toDouble(),
      min: this.min.toDouble(),
      divisions: (this.max - this.min).toInt(),
      label: currentValue.toString(),
      onChanged: changeSliderValue,
    );
  }

  void changeSliderValue(double value) {
    setState(() {
      currentValue = value.round();
    });
  }
}
