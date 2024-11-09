import 'package:flutter/material.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_grading_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_legend_widget.dart';

class HostInterface extends StatefulWidget {
  HostInterface({super.key});

  @override
  State<HostInterface> createState() => _HostInterfaceState();
}

class _HostInterfaceState extends State<HostInterface> {
  bool isLastButton = false;
  bool isResultPage = false;

  GameService gameService = GameService();
  HostInterfaceManagementService hostInterfaceManagementService =
      HostInterfaceManagementService();
  SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    if (_socketService.isSocketAlive() && !hostInterfaceManagementService.isAlreadyInit) {
      hostInterfaceManagementService.configureBaseSocketFeatures(context);
      gameService.init(gameService.realGameService.roomId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: Listenable.merge([
                        gameService.realGameService,
                        gameService,
                        hostInterfaceManagementService
                      ]),
        builder: (context, snapshot) {
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
                HostHeader(
                  isLastButton: isLastButton,
                  isResultPage: isResultPage,
                  gameService: gameService,
                  hostInterfaceManagementService: hostInterfaceManagementService,
                ),
                HostMiddleSection(
                  gameService: gameService,
                  hostInterfaceManagementService: hostInterfaceManagementService,
                ),
                PlayersDataTable(),
              ],
            );
          }
        },
      ),
    );
  }
}

class HostHeader extends StatelessWidget {
  bool isLastButton;
  bool isResultPage;
  final GameService gameService;
  final HostInterfaceManagementService hostInterfaceManagementService;

  HostHeader({
    required this.isLastButton,
    required this.isResultPage,
    required this.gameService,
    required this.hostInterfaceManagementService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TimerWidget(
          isHost: true,
          timeTxt: hostInterfaceManagementService.timerText,
          time: gameService.realGameService.timer,
          hostInterfaceManagementService: hostInterfaceManagementService,
        ),
        QuestionInfoWidget(
          questionNum: gameService.questionNumber,
          questionPts: gameService.question!.points,
          questionText: gameService.question!.text,
        ),
        TextButton(
          onPressed: () {
            hostInterfaceManagementService.saveStats();
            if (isLastButton) {
              isResultPage = true;
            }
            if (gameService.realGameService.isLast) {
              gameService.realGameService.isNotified = false;
              hostInterfaceManagementService.handleLastQuestion();
              isLastButton = true;
            } else {
              gameService.realGameService.isNotified = false;
              hostInterfaceManagementService.requestNextQuestion();
            }
          },
          child: Text(
            isLastButton ? 'Dernière question' : 'Prochaine question',
            style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.normal),
            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
          ),
        ),
        QuitBtn(isHost: true, roomId: gameService.realGameService.roomId),
      ],
    );
  }
}

class HostMiddleSection extends StatelessWidget {
  final GameService gameService;
  final HostInterfaceManagementService hostInterfaceManagementService;

  HostMiddleSection({
    required this.gameService,
    required this.hostInterfaceManagementService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: gameService.question!.type == QuestionType.QCM,
          child: Column(
            children: [HistogramLegend(), Histogram()],
          ),
        ),
        Visibility(
          visible: hostInterfaceManagementService.isHostEvaluating,
          child: HostGrading(
            gameStats: hostInterfaceManagementService.gameStats,
            qrlAnswers: hostInterfaceManagementService.responsesQRL,
          ),
        ),
      ],
    );
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
