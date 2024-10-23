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
              } else {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TimerWidget(isHost: true, time: gameService.timer),
                        QuestionInfoWidget(
                          questionNum: gameService.questionNumber,
                          questionPts: gameService.question!.points,
                          questionText: gameService.question!.text,
                        ),
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
                              isLastButton = gameService.realGameService.isLast;
                              if (isLastButton) {
                                hostInterfaceManagementService
                                    .handleLastQuestion();
                              } else {
                                hostInterfaceManagementService
                                    .requestNextQuestion();
                              }
                            },
                            child: Text(
                              'Prochaine question',
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
                        QuitBtn()
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Visibility(
                        visible: gameService.question!.type ==
                            QuestionType
                                .QCM, // gameService.question!.type null question when load
                        child: HistogramLegend()),
                    Visibility(
                        visible: gameService.question!.type ==
                            QuestionType.QCM, // null question when load
                        child: Histogram()),
                    Visibility(
                        visible:
                            hostInterfaceManagementService.isHostEvaluating,
                        child: HostGrading(
                          playerName: 'Player1',
                          playerAnswer: 'Answer answer answer',
                        )),
                    PlayersDataTableLegend(),
                    SizedBox(height: 20.0),
                    PlayersDataTable()
                  ],
                );
              }
            }));
  }
}
