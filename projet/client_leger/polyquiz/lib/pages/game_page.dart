import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_interface_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qrl_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_notice.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';

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
  GameInterfaceManagementService _gameInterfaceManagementService =
      GameInterfaceManagementService();

  @override
  void initState() {
    super.initState();
    this.isHost = this._gameService.realGameService.username == 'host';
    if (_socketService.isSocketAlive() && !_interactiveListService.isAlreadyInit) {
      print('GamePage initState');
      _interactiveListService.configureBaseSocketFeatures();
    }
    if (_socketService.isSocketAlive()) {
      if (!isHost) {
        print('I am Here');
        this._gameInterfaceManagementService.gameService.isOfflineMode = false;
        this
            ._gameInterfaceManagementService
            .setUp(this._gameService.realGameService.roomId.toString());
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if we're actually leaving the game
    print('GamePage dispose');
    if (_gameInterfaceManagementService.isGameOver) {
       print('GamePage dispose');
      final String socketMessage =
          this.isHost ? SocketEvent.HOST_LEFT : SocketEvent.PLAYER_LEFT;
      if (this._socketService.isSocketAlive()) {
        this._socketService.sendMessage(
            socketMessage, this._gameService.realGameService.roomId);
      }
      this._gameService.destroy();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PolyQuiz'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(53, 121, 246, 1),
        ),
        body: ListView(
            children: [Visibility(visible: isHost, child: HostInterface())]),
      );
    } else {
      return Container(
          child: AnimatedBuilder(
              animation:
                  _gameInterfaceManagementService.gameService.realGameService,
              builder: (BuildContext context, Widget? snapshot) {
                if (_gameInterfaceManagementService.gameService.question ==
                    null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Waiting for questions to load...',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                } else {
                  return AnimatedBuilder(
                      animation: Listenable.merge([
                        _gameInterfaceManagementService,
                        _gameInterfaceManagementService.gameService
                      ]),
                      builder: (BuildContext context, Widget? snapshot) {
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
                                          timeTxt:
                                              _gameInterfaceManagementService
                                                  .timerText,
                                          time: _gameInterfaceManagementService
                                              .gameService.timer,
                                        ),
                                      ),
                                      QuestionInfoWidget(
                                          questionNum:
                                              _gameInterfaceManagementService
                                                  .gameService.questionNumber,
                                          questionPts:
                                              _gameInterfaceManagementService
                                                  .gameService.question!.points,
                                          questionText:
                                              _gameInterfaceManagementService
                                                  .gameService.question!.text),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.all(5.0),
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                              border: Border.all()),
                                          child: Text(
                                            'Pointage: ${_gameInterfaceManagementService.playerScore}',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Visibility(
                                      visible: _gameInterfaceManagementService
                                                  .gameService.question?.type ==
                                              QuestionType.QCM &&
                                          !noticeReceived,
                                      child: Container(
                                          height: 500, child: PlayerQcm())),
                                  Visibility(
                                      visible: _gameInterfaceManagementService
                                                  .gameService.question?.type ==
                                              QuestionType.QRL &&
                                          !noticeReceived,
                                      child: PlayerQrl(
                                          gameInterfaceManagementService:
                                              _gameInterfaceManagementService)),
                                  Visibility(
                                    visible: noticeReceived,
                                    child: FutureBuilder(
                                      future: _gameInterfaceManagementService
                                                      .gameService
                                                      .lastQrlScore !=
                                                  null &&
                                              _gameInterfaceManagementService
                                                      .gameService
                                                      .isHostEvaluating ==
                                                  false
                                          ? Future.delayed(Duration(seconds: 4),
                                              () {
                                              setState(() {
                                                noticeReceived = false;
                                              });
                                            })
                                          : Future.value(null),
                                      builder: (context, snapshot) {
                                        return PlayerNotice(
                                          message: message,
                                          gameInterfaceManagementService:
                                              _gameInterfaceManagementService,
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: !noticeReceived,
                                        child: TextButton(
                                          onPressed: () {
                                            if (_gameInterfaceManagementService
                                                    .gameService
                                                    .question
                                                    ?.type ==
                                                QuestionType.QRL) {
                                              _gameInterfaceManagementService
                                                  .gameService
                                                  .isHostEvaluating = true;
                                              this.noticeReceived = true;
                                            }
                                            _gameInterfaceManagementService
                                                .gameService
                                                .sendAnswer();
                                          },
                                          child: Text(
                                            'Confirmer',
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize: 20),
                                          ),
                                          style: TextButton.styleFrom(
                                              textStyle: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal),
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              backgroundColor: Color.fromRGBO(
                                                  53, 121, 246, 1)),
                                        ),
                                      ),
                                      SizedBox(width: 100.0),
                                      QuitBtn(
                                          isHost: false,
                                          roomId: this
                                              ._gameService
                                              .realGameService
                                              .roomId),
                                      ChatPopup()
                                    ],
                                  )
                                ],
                              ),
                            ), //////////////////// Fin de la vue du joueur et debut de la vue de l'organisateur
                          ]),
                        );
                      });
                }
              }));
    }
  }
}
