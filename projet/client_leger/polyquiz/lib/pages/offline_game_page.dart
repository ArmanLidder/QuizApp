import 'dart:async';
import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_notice.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';

class OfflineGamePage extends StatefulWidget {
  const OfflineGamePage({super.key});

  @override
  State<OfflineGamePage> createState() => _OfflineGamePageState();
}

class _OfflineGamePageState extends State<OfflineGamePage> {
  GameInterfaceManagementService gameInterfaceManagementService =
      GameInterfaceManagementService();
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();
  GameService _gameService = GameService();

  bool noticeReceived = false;
  String message = "Attendez pendant que l'hôte corrige les réponses...";
  int currentTime = 0;
  bool isTimerTransition = false;
  bool isLastQuestion = false;
  bool isFinalTransition = false;
  Timer? _timer;

  void handleTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        currentTime--;
        if (currentTime == 0 && isFinalTransition) {
          _globalNavigationService.navigateTo('/auth');
        } else if (currentTime == 0 && !isTimerTransition) {
          gameInterfaceManagementService.gameService.sendAnswer();
          this.isLastQuestion = !_gameService.offlineGameService.next();
          this.isTimerTransition = true;
          this.currentTime = 3;
          this.gameInterfaceManagementService.changeQcmEnabled(false);
          if (this.isLastQuestion) this.isFinalTransition = true;
        } else if (currentTime == 0 && isTimerTransition) {
          this.isTimerTransition = false;
          this.currentTime = this._gameService.offlineGameService.quiz.duration;
          this.gameInterfaceManagementService.changeQcmEnabled(true);
        }
      });
    });
  }

  @override
  void initState() {
    _gameService.offlineGameService.init();
    this.currentTime = this._gameService.offlineGameService.quiz.duration;
    this.handleTimer();
    super.initState();
  }

  @override
  void dispose() {
    this._gameService.destroy();
    this.gameInterfaceManagementService.reset();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
            animation:
                gameInterfaceManagementService.gameService.offlineGameService,
            builder: (BuildContext context, Widget? snapshot) {
              if (gameInterfaceManagementService.gameService.question == null) {
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
                      gameInterfaceManagementService,
                      gameInterfaceManagementService.gameService
                    ]),
                    builder: (BuildContext context, Widget? snapshot) {
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('PolyQuiz'),
                          automaticallyImplyLeading: false,
                          centerTitle: true,
                          backgroundColor: Color.fromRGBO(53, 121, 246, 1),
                        ),
                        body: ListView(children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TimerWidget(
                                      isHost: false,
                                      timeTxt: gameInterfaceManagementService
                                          .timerText,
                                      time: this.currentTime,
                                    ),
                                  ),
                                  if (!isTimerTransition && !isFinalTransition)
                                    QuestionInfoWidget(
                                        questionNum:
                                            gameInterfaceManagementService
                                                .gameService.questionNumber,
                                        questionPts:
                                            gameInterfaceManagementService
                                                .gameService.question!.points,
                                        questionText:
                                            gameInterfaceManagementService
                                                .gameService.question!.text),
                                  if (isTimerTransition || isFinalTransition)
                                    QuestionInfoWidget(
                                        questionNum: isFinalTransition
                                            ? gameInterfaceManagementService
                                                .gameService.questionNumber
                                            : gameInterfaceManagementService
                                                    .gameService
                                                    .questionNumber -
                                                1,
                                        questionPts: this
                                            ._gameService
                                            .offlineGameService
                                            .oldQuestion
                                            .points,
                                        questionText: this
                                            ._gameService
                                            .offlineGameService
                                            .oldQuestion
                                            .text),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(5.0),
                                      padding: EdgeInsets.all(10.0),
                                      decoration:
                                          BoxDecoration(border: Border.all()),
                                      child: Text(
                                        'Pointage: ${gameInterfaceManagementService.gameService.offlineGameService.playerScore}',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Visibility(
                                  visible: gameInterfaceManagementService
                                              .gameService.question?.type ==
                                          QuestionType.QCM &&
                                      !noticeReceived,
                                  child: Container(
                                      height: 500,
                                      child: AnimatedBuilder(
                                          animation:
                                              gameInterfaceManagementService,
                                          builder: (BuildContext context,
                                              Widget? snapshot) {
                                            return PlayerQcm();
                                          }))),
                              Visibility(
                                visible: noticeReceived,
                                child: FutureBuilder(
                                  future: gameInterfaceManagementService
                                                  .gameService.lastQrlScore !=
                                              null &&
                                          gameInterfaceManagementService
                                                  .gameService
                                                  .realGameService
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
                                          gameInterfaceManagementService,
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
                                      onPressed: this.isFinalTransition ||
                                              this.isTimerTransition
                                          ? () {}
                                          : () {
                                              gameInterfaceManagementService
                                                  .gameService
                                                  .sendAnswer();
                                              if (!gameInterfaceManagementService
                                                  .gameService
                                                  .offlineGameService
                                                  .next()) {
                                                this.currentTime = 3;
                                                this.isTimerTransition = true;
                                                this.isFinalTransition = true;
                                                this
                                                    .gameInterfaceManagementService
                                                    .changeQcmEnabled(false);
                                              } else {
                                                this.currentTime = 3;
                                                this.isTimerTransition = true;
                                                this
                                                    .gameInterfaceManagementService
                                                    .changeQcmEnabled(false);
                                              }
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
                                              fontWeight: FontWeight.normal),
                                          splashFactory: NoSplash.splashFactory,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                          backgroundColor:
                                              Color.fromRGBO(53, 121, 246, 1)),
                                    ),
                                  ),
                                  SizedBox(width: 100.0),
                                  TextButton(
                                    onPressed: () {
                                      _globalNavigationService
                                          .navigateTo('/auth');
                                    },
                                    child: Text(
                                      'Quitter',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          fontSize: 20),
                                    ),
                                    style: TextButton.styleFrom(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.normal),
                                        splashFactory: NoSplash.splashFactory,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor:
                                            Color.fromRGBO(246, 53, 53, 1)),
                                  )
                                ],
                              )
                            ],
                          ),
                        ]),
                      );
                    });
              }
            }));
  }
}
