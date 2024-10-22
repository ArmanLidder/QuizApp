import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_interface_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qrl_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_notice.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GamePage> {
  late bool isHost;
  bool isQcm = false; // Il faudra remplacer par un enum par la suite
  bool noticeReceived = false;
  bool isGrading = true;
  int time = 10;
  int questionNum = 1;
  int questionPts = 50;
  String questionTxt = "Question par defaut ?";
  String message = "Attendez pendant que l'hôte corrige les réponses...";
  GameService _gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();

  @override
  void initState() {
    super.initState();
    if (_socketService.isSocketAlive()) {
      _interactiveListService.configureBaseSocketFeatures();
      this.isHost = this._gameService.realGameService.username == 'host';
    }
  }

  @override
  void dispose() {
    final String socketMessage =
        this.isHost ? SocketEvent.HOST_LEFT : SocketEvent.PLAYER_LEFT;
    if (this._socketService.isSocketAlive()) {
      this
          ._socketService
          .sendMessage(socketMessage, this._gameService.realGameService.roomId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isHost){
      return Scaffold(
        appBar: AppBar(
          title: const Text('PolyQuiz'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(53, 121, 246, 1),
        ),
        body: ListView(children: [
        Visibility(visible: isHost, child: HostInterface())
        ]),
      );
    }
    else {
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
                        timeTxt: 'Temps restant',
                        time: time,
                      ),
                    ),
                    QuestionInfoWidget(
                        questionNum: questionNum, questionPts: questionPts, questionTxt: questionTxt),
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
                    child: PlayerNotice(message: message)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !noticeReceived,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Confirmer',
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 20),
                        ),
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontWeight: FontWeight.normal),
                            splashFactory: NoSplash.splashFactory,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                            backgroundColor: Color.fromRGBO(53, 121, 246, 1)),
                      ),
                    ),
                    SizedBox(width: 100.0),
                    QuitBtn()
                  ],
                )
              ],
            ),
          ), //////////////////// Fin de la vue du joueur et debut de la vue de l'organisateur
      ]),  
    );
    }
  }
}
