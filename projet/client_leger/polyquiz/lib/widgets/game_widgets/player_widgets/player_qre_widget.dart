import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart' as Quiz;
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'dart:math' as math;

import 'package:polyquiz/services/translationService.dart';

class PlayerQreWidget extends StatefulWidget {
  const PlayerQreWidget({super.key});

  @override
  State<PlayerQreWidget> createState() => _PlayerQreWidgetState();
}

class _PlayerQreWidgetState extends State<PlayerQreWidget> {
  ThemeService _themeService = ThemeService.instance;
  GameInterfaceManagementService gameInterfaceManagementService = GameInterfaceManagementService();
  bool get isValidated => !gameInterfaceManagementService.gameService.realGameService.isValidateActive;
  int _currentValue = 0;  // TODO: attach this to gameService maybe
  int get currentValue {
    if (this.gameInterfaceManagementService.gameService.isObserverMode) return this.gameInterfaceManagementService.gameService.obsQreAnswer;
    return this.gameInterfaceManagementService.gameService.qreAnswer;
  }
  void set currentValue(int value) { this.gameInterfaceManagementService.gameService.qreAnswer = value; }
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get qreText => gameText['PLAYER_QRE_INTERFACE'];

  @override
  void initState() {
    super.initState();
    if (question != null && question?.interval != null) {
      final max = question!.interval!.max;
      final min = question!.interval!.min;
      if (this.gameInterfaceManagementService.gameService.isObserverMode) this.gameInterfaceManagementService.gameService.obsQreAnswer = min.toInt();
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
    return Container(
      child: Center(
        child: AnimatedBuilder(
          animation: gameInterfaceManagementService.gameService.realGameService,
          builder: (BuildContext context, Widget? snapshot) => Card(
            color: _themeService.mainBackground.value,
            elevation: 5.0,
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  getMinMaxCard(),
                  // getIncrementalAdjustmentButtons(),
                  getSlider(),
                  getToleranceWidget(),
                  getIntervalWidget(),
                  // getButtons()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getMinMaxCard() {
    const numberPadding = 70.0;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: numberPadding),
          child: Text(this.min.toString(),
              style: TextStyle(color: _themeService.mainAccent.value)),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: numberPadding),
          child: Text(this.max.toString(),
              style: TextStyle(color: _themeService.mainAccent.value)),
        )
      ],
    );
  }

  Widget getIncrementalAdjustmentButtons() {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: canDecrement ? decrementSlider : null,
          icon: Icon(Icons.add),
          color: canDecrement
              ? _themeService.secondaryBackground.value
              : Colors.grey,
        ),
        Spacer(),
        IconButton(
          onPressed: canIncrement ? incrementSlider : null,
          icon: Icon(Icons.remove),
          color: canIncrement
              ? _themeService.secondaryBackground.value
              : Colors.grey,
        ),
      ],
    );
  }

  Widget getSlider() {
    return Row(
      children: [
        IconButton(
          onPressed: canDecrement ? decrementSlider : null,
          icon: Icon(Icons.remove),
          color: _themeService.secondaryAccent.value,
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(canDecrement
                  ? _themeService.secondaryBackground.value
                  : Colors.grey)),
        ),
        Expanded(
          child: Slider(
            activeColor: _themeService.secondaryBackground.value,
            value: currentValue.toDouble(),
            max: this.max.toDouble(),
            min: this.min.toDouble(),
            divisions: (this.max - this.min).toInt(),
            label: currentValue.toString(),
            onChanged: (value) {
              setState(() {
                if (isValidated) return;
                currentValue = value.round();
              });
            },
            onChangeEnd: changeSliderValue,
          ),
        ),
        IconButton(
          onPressed: canIncrement ? incrementSlider : null,
          icon: Icon(Icons.add),
          color: _themeService.secondaryAccent.value,
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                  canIncrement ? Colors.blueAccent : Colors.grey)),
        )
      ],
    );
  }

  Widget getToleranceWidget() {
    return Center(
      child: Text("${qreText['TOLERANCE']}: ±${this.question?.margin ?? 0}",
          style: TextStyle(color: _themeService.mainAccent.value)),
    );
  }

  Widget getIntervalWidget() {
    final margin = this.question?.margin ?? 0;
    final maxValue = math.min(this.max, currentValue + margin);
    final minValue = math.max(this.min, currentValue - margin);
    return Center(
      child: Text("${qreText['YOUR_ANSWER_INTERVAL']} $minValue - $maxValue",
          style: TextStyle(color: _themeService.mainAccent.value)),
    );
  }

  Widget getButtons() {
    final validTextStyle = TextButton.styleFrom(
      backgroundColor:
          isValidated ? Colors.grey : _themeService.secondaryBackground.value,
      foregroundColor: _themeService.secondaryAccent.value,
    );
    final quitTextStyle = TextButton.styleFrom(
        backgroundColor: Colors.red, foregroundColor: Colors.white);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: !isValidated ? onValidate : null,
          child: Text("Valider"),
          style: validTextStyle,
        ),
        SizedBox(
          width: 10,
        ),
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
    gameInterfaceManagementService.gameService.selectQREanswer(currentValue);
    gameInterfaceManagementService.gameService.sendAnswer();
  }

  void onQuit() {
    // TODO: to change later
  }

  void changeSliderValue(double value) {
    if (isValidated || this.gameInterfaceManagementService.gameService.isObserverMode) return;
    setState(() {
      currentValue = value.round();
    });
    gameInterfaceManagementService.gameService.selectQREanswer(currentValue);
  }

  bool get canIncrement {
    return !(isValidated || (currentValue >= this.max) || this.gameInterfaceManagementService.gameService.isObserverMode);
  }

  bool get canDecrement {
    return !(isValidated || (currentValue <= this.min) || this.gameInterfaceManagementService.gameService.isObserverMode);
  }

  void incrementSlider() {
    if (canIncrement) changeSliderValue(currentValue + 1);
  }

  void decrementSlider() {
    if (canDecrement) changeSliderValue(currentValue - 1);
  }
}
