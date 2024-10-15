import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qrl_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_notice.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_legend_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GamePage> {
  bool isHost = true;
  bool isQcm = false; // Il faudra remplacer par un enum par la suite
  bool noticeReceived = false;
  int time = 10;
  int questionNum = 1;
  int questionPts = 50;
  String message = 'Please wait while the host grades the answers...';
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
                  QuestionInfoWidget(
                      questionNum: questionNum, questionPts: questionPts),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(5.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Text(
                        'Score: 0',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                  visible: isQcm && !noticeReceived,
                  child: Container(height: 500, child: PlayerQcm())),
              Visibility(
                  visible: !isQcm && !noticeReceived, child: PlayerQrl()),
              Visibility(
                  visible: noticeReceived,
                  child: PlayerNotice(
                    message: message,
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !noticeReceived,
                    child: TextButton(
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
                  ),
                  SizedBox(
                    width: 100.0,
                  ),
                  QuitBtn()
                ],
              )
            ],
          ),
        ), //////////////////// Fin de la vue du joueur et debut de la vue de l'organisateur
        Visibility(
            visible: isHost,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TimerWidget(isHost: isHost, time: time),
                    QuestionInfoWidget(
                        questionNum: questionNum, questionPts: questionPts),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !noticeReceived,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Next Question',
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
                    ),
                    SizedBox(
                      width: 100.0,
                    ),
                    QuitBtn()
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                HistogramLegend(),
                Histogram(),
                PlayersDataTable()
              ],
            ))
      ]),
    );
  }
}
