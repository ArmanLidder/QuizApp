import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart' as Quiz;
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'dart:math' as math;

class PlayerQreWidget extends StatefulWidget {
  const PlayerQreWidget({super.key});

  @override
  State<PlayerQreWidget> createState() => _PlayerQreWidgetState();
}

class _PlayerQreWidgetState extends State<PlayerQreWidget> {
  GameInterfaceManagementService gameInterfaceManagementService = GameInterfaceManagementService();
  bool get isValidated => !gameInterfaceManagementService.gameService.realGameService.isValidateActive;
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
    return gameInterfaceManagementService.gameService.question;
    // return defaultQuestion;
  }

  num get max {
    return question?.interval?.max ?? 1;
  }

  num get min {
    return question?.interval?.min ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: gameInterfaceManagementService.gameService.realGameService,
        builder: (BuildContext context, Widget? snapshot) => Card(
          elevation: 5.0,
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getMinMaxCard(),
                getIncrementalAdjustmentButtons(),
                getSlider(),
                getToleranceWidget(),
                getIntervalWidget(),
                // getButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMinMaxCard() {
    return Row(
      children: [
        Text(this.min.toString()),
        Spacer(),
        Text(this.max.toString())
      ],
    );
  }

  Widget getIncrementalAdjustmentButtons() {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: canDecrement ? decrementSlider : null,
          icon: Icon(Icons.add),
          color: canDecrement ? Colors.blueAccent : Colors.grey,
        ),
        Spacer(),
        IconButton(
          onPressed: canIncrement ? incrementSlider : null,
          icon: Icon(Icons.remove),
          color: canIncrement ? Colors.blueAccent : Colors.grey,
        ),
      ],
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

  Widget getToleranceWidget() {
    return Center(
      child: Text("Tolérance: ±${this.question?.margin ?? 0}"),
    );
  }

  Widget getIntervalWidget() {
    final margin = this.question?.margin ?? 0;
    final maxValue = math.min(this.max, currentValue + margin);
    final minValue = math.max(this.min, currentValue - margin);
    return Center(
      child: Text("Votre intervalle de réponse est: $minValue à $maxValue"),
    );
  }

  Widget getButtons() {
    final validTextStyle = TextButton.styleFrom(
      backgroundColor: isValidated ? Colors.grey : Colors.blueAccent,
      foregroundColor: Colors.white,
    );
    final quitTextStyle = TextButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
            onPressed: !isValidated ? onValidate : null,
            child: Text("Valider"),
            style: validTextStyle,
        ),
        SizedBox(width: 10,),
        TextButton(
            onPressed: onQuit,
            child: Text("Quitter"),
            style: quitTextStyle,
        )
      ],
    );
  }

  void onValidate() {
    // setState(() {
    //   isValidated = true;
    // });
    gameInterfaceManagementService.gameService.qreAnswer = currentValue;
    gameInterfaceManagementService.gameService.sendAnswer();
  }

  void onQuit() {
    // TODO: to change later
  }

  void changeSliderValue(double value) {
    if (isValidated) return;
    gameInterfaceManagementService.gameService.qreAnswer = currentValue;
    setState(() {
      currentValue = value.round();
    });
  }

  bool get canIncrement {
    return !(isValidated || (currentValue >= this.max));
  }

  bool get canDecrement {
    return !(isValidated || (currentValue <= this.min));
  }

  void incrementSlider() {
    if (canIncrement) changeSliderValue(currentValue + 1);
  }

  void decrementSlider() {
    if (canDecrement) changeSliderValue(currentValue - 1);
  }
}
