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
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';

class HostInterface extends StatefulWidget {
  final InteractiveListService? interactiveListService;
  final GameInterfaceManagementService? gameInterfaceManagementService;

  HostInterface({Key? key, this.interactiveListService, this.gameInterfaceManagementService})
      : super(key: key);

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
    print('isSocketAlive: ${_socketService.isSocketAlive()}');
    print('isAlreadyInit host interface: ${hostInterfaceManagementService.isAlreadyInit}');
    if (_socketService.isSocketAlive() && !hostInterfaceManagementService.isAlreadyInit) {
      hostInterfaceManagementService.configureBaseSocketFeatures(context);
      gameService.init(gameService.realGameService.roomId.toString());
    }
  }

  void _handleLastQuestion() {
    setState(() {
      isResultPage = true;
      isLastButton = true;
    });
    hostInterfaceManagementService.handleLastQuestion();
  }

  void _handleNextQuestion() {
    hostInterfaceManagementService.saveStats();
    if (gameService.realGameService.isLast) {
      _handleLastQuestion();
    } else {
      gameService.realGameService.isNotified = false;
      hostInterfaceManagementService.requestNextQuestion();
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
            return ResultPage(
              gameService: gameService,
              hostInterfaceManagementService: hostInterfaceManagementService,
              interactiveListService: widget.interactiveListService,
              gameInterfaceManagementService: widget.gameInterfaceManagementService,
            );
          } else {
            return Column(
              children: [
                HostHeader(
                  isLastButton: gameService.realGameService.isLast,
                  onNextQuestion: _handleNextQuestion,
                  gameService: gameService,
                  hostInterfaceManagementService: hostInterfaceManagementService,
                  interactiveListService: widget.interactiveListService,
                  gameInterfaceManagementService: widget.gameInterfaceManagementService,
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
  final VoidCallback onNextQuestion;
  final GameService gameService;
  final HostInterfaceManagementService hostInterfaceManagementService;
  final InteractiveListService? interactiveListService;
  final GameInterfaceManagementService? gameInterfaceManagementService;

  HostHeader({
    required this.isLastButton,
    required this.onNextQuestion,
    required this.gameService,
    required this.hostInterfaceManagementService,
    this.interactiveListService,
    this.gameInterfaceManagementService,
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
          onPressed: onNextQuestion,
          // () 
          // {
            // hostInterfaceManagementService.saveStats();
            // if (gameService.realGameService.isLast) {
            //   isResultPage = true;
            // }
            // if (gameService.realGameService.isLast) {
            //   print('isLast');
            //   gameService.realGameService.isNotified = false;
            //   hostInterfaceManagementService.handleLastQuestion();
            //   isLastButton = true;
            // } 
            // else {
            //   gameService.realGameService.isNotified = false;
            //   hostInterfaceManagementService.requestNextQuestion();
            // }
            
          // },
          child: Text(
            gameService.realGameService.isLast ? 'Dernière question' : 'Prochaine question',
            style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
          ),
          style: TextButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.normal),
            backgroundColor: Color.fromRGBO(53, 121, 246, 1),
          ),
        ),
        QuitBtn(isHost: true, roomId: gameService.realGameService.roomId, gameService: gameService, interactiveListService: interactiveListService, gameInterfaceManagementService: gameInterfaceManagementService,hostInterfaceManagementService: hostInterfaceManagementService),
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
  final GameService gameService;
  final InteractiveListService? interactiveListService;
  final GameInterfaceManagementService? gameInterfaceManagementService;
  final HostInterfaceManagementService hostInterfaceManagementService;

  ResultPage({
    required this.gameService,
    this.interactiveListService,
    this.gameInterfaceManagementService,
    required this.hostInterfaceManagementService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Game Over! Here are the results.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        QuitBtn(
          isHost: true,
          roomId: gameService.realGameService.roomId,
          gameService: gameService,
          interactiveListService: interactiveListService,
          gameInterfaceManagementService: gameInterfaceManagementService,
          hostInterfaceManagementService: hostInterfaceManagementService,
        ),
      ],
    );
  }
}
