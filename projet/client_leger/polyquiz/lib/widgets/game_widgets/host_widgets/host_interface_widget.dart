import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/qrl_evaluation_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_legend_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_grading_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_legend_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';

class HostInterface extends StatefulWidget {
  HostInterface({super.key});

  @override
  State<HostInterface> createState() => _HostInterfaceState();
}

class _HostInterfaceState extends State<HostInterface> {
  bool isLastButton = false;
  bool isResultPage = false;

  QrlEvaluationService qrlEvaluationService = QrlEvaluationService();
  GameService gameService = GameService();
  HostInterfaceManagementService hostInterfaceManagementService =
      HostInterfaceManagementService();
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();
  SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    if (this._socketService.isSocketAlive()) {
      this.hostInterfaceManagementService.configureBaseSocketFeatures();
      this.gameService.init(this.gameService.realGameService.roomId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: AnimatedBuilder(
            animation: gameService.realGameService,
            builder: (BuildContext context, Widget? snapshot) {
              if (gameService.question == null) {
                return Center(
                  child: Text(
                    'Waiting for questions to load...',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              } else if (isResultPage) {
                return ResultPage();
              } else {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedBuilder(
                            animation: gameService,
                            builder: (BuildContext context, Widget? snapshot) {
                              return TimerWidget(
                                  isHost: true,
                                  timeTxt:
                                      hostInterfaceManagementService.timerText,
                                  time: gameService.realGameService.timer,
                                  hostInterfaceManagementService:
                                      hostInterfaceManagementService);
                            }),
                        AnimatedBuilder(
                            animation: gameService,
                            builder: (BuildContext context, Widget? snapshot) {
                              return QuestionInfoWidget(
                                  questionNum: gameService.questionNumber,
                                  questionPts: gameService.question!.points,
                                  questionText: gameService.question!.text);
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: true, // a changer plus tard
                          child: TextButton(
                            onPressed: () {
                              hostInterfaceManagementService.saveStats();
                              if (isLastButton) {
                                isResultPage = true;
                              }
                              if (gameService.realGameService.isLast) {
                                gameService.realGameService.isNotified = false;
                                hostInterfaceManagementService
                                    .handleLastQuestion();
                                isLastButton = true;
                              } else {
                                gameService.realGameService.isNotified = false;
                                hostInterfaceManagementService
                                    .requestNextQuestion();
                              }
                            },
                            child: Text(
                              isLastButton
                                  ? 'Dernière question'
                                  : 'Prochaine question',
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 20),
                            ),
                            style: TextButton.styleFrom(
                                textStyle:
                                    TextStyle(fontWeight: FontWeight.normal),
                                splashFactory: NoSplash.splashFactory,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                backgroundColor:
                                    Color.fromRGBO(53, 121, 246, 1)),
                          ),
                        ),
                        SizedBox(
                          width: 100.0,
                        ),
                        QuitBtn(),
                        ElevatedButton(
                          onPressed: () {
                            print(this._socketService.isSocketAlive());
                          },
                          child: Text('Check Socket Status'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    AnimatedBuilder(
                        animation: gameService,
                        builder: (BuildContext context, Widget? snapshot) {
                          return Column(
                            children: [
                              Visibility(
                                  visible: gameService.question!.type ==
                                      QuestionType.QCM,
                                  child: HistogramLegend()),
                              Visibility(
                                  visible: gameService.question!.type ==
                                      QuestionType.QCM,
                                  child: Histogram()),
                            ],
                          );
                        }),
                    AnimatedBuilder(
                        animation: hostInterfaceManagementService,
                        builder: (BuildContext context, Widget? snapshot) {
                          return Visibility(
                              visible: hostInterfaceManagementService
                                  .isHostEvaluating,
                              child: HostGrading(
                                  gameStats:
                                      hostInterfaceManagementService.gameStats,
                                  qrlAnswers: hostInterfaceManagementService
                                      .responsesQRL));
                        }),
                    PlayersDataTableLegend(),
                    SizedBox(height: 20.0),
                    PlayersDataTable()
                  ],
                );
              }
            }));
  }
}

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Game Over! Here are the results.',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
