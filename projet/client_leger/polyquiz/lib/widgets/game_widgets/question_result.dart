import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/histogram_result_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_legend_widget.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/models/typedefs.dart';


class StatisticZone extends StatefulWidget {
  final List<QuestionStatistics> gameStats;

  StatisticZone({required this.gameStats});

  @override
  _StatisticZoneState createState() => _StatisticZoneState();
}

class _StatisticZoneState extends State<StatisticZone> {
  late QuestionStatistics? currentStat;
  int index = 0;
  late Map<String, bool> responseValue;
  late Map<String, num> responseNumber;
  QuizQuestion? question;
  Map get transText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get qreValueText => transText['QRE_HISTOGRAM_X_VAL'];
  final validateButtonStyle = TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Color.fromRGBO(53, 121, 246, 1),
  );

  @override
  void initState() {
    super.initState();
    if (widget.gameStats.isNotEmpty) {
      currentStat = widget.gameStats[index];
      setUpData();
    }
  }

  @override
  void dispose() {
    this.responseValue.clear();
    this.responseNumber.clear();
    this.question = null;
    this.index = 0;
    this.currentStat = null;
    super.dispose();
  }

  void initGraph(QuizQuestion question, int numberOfPlayers) {
    switch (question.type) {
      case QuestionType.QCM:
        print('INIT GRAPH GOT INTO THE IF');
        if (question.choices == null) {
          return;
        }
        for (QuizChoice choice in question.choices!) {
          this.responseValue[choice.text] = choice.isCorrect!;
          this.responseNumber[choice.text] = 0;
        }
        break;
      case QuestionType.QRL:
        this.responseValue = {
          'Actif': true,
          'Inactif': false,
        };
        this.responseNumber = {
          'Actif': 0,
          'Inactif': numberOfPlayers,
        };
        break;
      case QuestionType.QRE:
        this.responseValue = {
          qreValueText['WITHIN_MARGIN']: true,
          qreValueText['EXACT_ANSWER']: true,
          qreValueText['INCORRECT_ANSWER']: false,
        };
        this.responseNumber = {
          qreValueText['WITHIN_MARGIN']: 0,
          qreValueText['EXACT_ANSWER']: 0,
          qreValueText['INCORRECT_ANSWER']: 0,
        };
        break;
      default:
    }
  }

  void next() {
    setState(() {
      currentStat = widget.gameStats[++index];
      setUpData();
    });
  }

  void previous() {
    setState(() {
      currentStat = widget.gameStats[--index];
      setUpData();
    });
  }

  bool isEnd() {
    return widget.gameStats.isNotEmpty ? index == widget.gameStats.length - 1 : true;
  }

  bool isFirst() {
    return index == 0;
  }

  void setUpData() {
    this.responseValue = this.currentStat!.responsesValues;
    this.responseNumber = this.currentStat!.responsesNumber;
    if (this.currentStat!.question != null)
      {this.question = this.currentStat!.question!;}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Question ${index + 1}', style: TextStyle(fontSize: 24)),
        if (currentStat!.question != null)
          Text(currentStat!.question!.text, style: TextStyle(fontSize: 18)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            if (!isFirst())
              Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
          onPressed: previous,
          child: Text('Précédent', style: TextStyle(color: Colors.white)),
          style: validateButtonStyle,
              ),
              ),
            if (!isEnd())
              Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
          onPressed: next,
          child: Text('Suivant', style: TextStyle(color: Colors.white)),
          style: validateButtonStyle,
              ),
              ),
            ],
        ),
        HistogramLegend(),
        Histogram(responseValue: responseValue, responseNumber: responseNumber),
      ],
    );
  }
}