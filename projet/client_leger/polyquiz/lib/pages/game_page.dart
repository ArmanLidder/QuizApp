import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qrl_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GamePage> {
  bool isHost = false;
  bool isQcm = false; // Il faudra remplacer par un enum par la suite
  int time = 10;
  int questionNum = 1;
  int questionPts = 50;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolyQuiz'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(53, 121, 246, 1),
      ),
      body: ListView(children: [
        Visibility(
          // Vue du joueur commence ici
          visible: !isHost,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TimerWidget(
                      isHost: isHost,
                      time: time,
                    ),
                  ),
                  PlayerQuestionInfoWidget(
                      questionNum: questionNum, questionPts: questionPts),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Text(
                        'Score: 200',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                  visible: isQcm,
                  child: Container(height: 500, child: PlayerQcmWidget())),
              Visibility(visible: !isQcm, child: PlayerQrlWidget()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(fontWeight: FontWeight.normal),
                        splashFactory: NoSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Color.fromRGBO(53, 121, 246, 1)),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Quit',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 20),
                    ),
                    style: TextButton.styleFrom(
                        textStyle: TextStyle(fontWeight: FontWeight.normal),
                        splashFactory: NoSplash.splashFactory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
                  ),
                ],
              )
            ],
          ),
        ),
        Visibility(visible: isHost, child: Text('host view'))
      ]),
    );
  }
}
