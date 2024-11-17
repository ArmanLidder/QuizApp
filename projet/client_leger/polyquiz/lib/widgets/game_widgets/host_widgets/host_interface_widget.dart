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

  HostInterface(
      {Key? key,
      this.interactiveListService,
      this.gameInterfaceManagementService})
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
    print(
        'isAlreadyInit host interface: ${hostInterfaceManagementService.isAlreadyInit}');
    if (_socketService.isSocketAlive() &&
        !hostInterfaceManagementService.isAlreadyInit) {
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
    this.hostInterfaceManagementService.NextQuestionBtnDisabled = true;
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
          } else if (isResultPage || hostInterfaceManagementService.isResultPage) {
            return ResultPage(
              gameService: gameService,
              hostInterfaceManagementService: hostInterfaceManagementService,
              interactiveListService: widget.interactiveListService,
              gameInterfaceManagementService:
                  widget.gameInterfaceManagementService,
            );
          } else {
            return Column(
              children: [
                HostHeader(
                  isLastButton: gameService.realGameService.isLast,
                  onNextQuestion: _handleNextQuestion,
                  gameService: gameService,
                  hostInterfaceManagementService:
                      hostInterfaceManagementService,
                  interactiveListService: widget.interactiveListService,
                  gameInterfaceManagementService:
                      widget.gameInterfaceManagementService,
                ),
                HostMiddleSection(
                  gameService: gameService,
                  hostInterfaceManagementService:
                      hostInterfaceManagementService,
                ),
                PlayersDataTable(
                  isHost: true,
                ),
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
    final validateButtonStyle = TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: FontWeight.normal),
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: this.hostInterfaceManagementService.NextQuestionBtnDisabled ? Colors.grey : Color.fromRGBO(53, 121, 246, 1),
    );
    return Stack(children: [
      Column(
        children: [
          Row(
            children: [
              TimerWidget(
                isHost: true,
                timeTxt: hostInterfaceManagementService.timerText,
                time: gameService.realGameService.timer,
                hostInterfaceManagementService: hostInterfaceManagementService,
              )
            ],
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              TextButton(
                onPressed: this.hostInterfaceManagementService.NextQuestionBtnDisabled ? null : onNextQuestion,
                child: Text(
                  gameService.realGameService.isLast
                      ? 'Résultats'
                      : 'Prochaine question',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
                ),
                style: validateButtonStyle,
              ),
              SizedBox(width: 50),
              QuitBtn(
                  isHost: true,
                  roomId: gameService.realGameService.roomId,
                  gameService: gameService,
                  interactiveListService: interactiveListService,
                  gameInterfaceManagementService:
                      gameInterfaceManagementService,
                  hostInterfaceManagementService:
                      hostInterfaceManagementService),
            ],
          )
        ],
      ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: QuestionInfoWidget(
            questionNum: gameService.questionNumber,
            questionPts: gameService.question!.points,
            questionText: gameService.question!.text,
          ),
        ),
      )
    ]);
  }
}

class HostMiddleSection extends StatelessWidget {
  final GameService gameService;
  final HostInterfaceManagementService hostInterfaceManagementService;

  HostMiddleSection({
    required this.gameService,
    required this.hostInterfaceManagementService,
  });

  Widget getHostInterface() {
    Widget? returnedWidget;
    QuestionType? type = gameService.question?.type ?? null;
    switch (type) {
      case QuestionType.QRL:
        returnedWidget = AnimatedBuilder(
          animation: hostInterfaceManagementService,
          builder: (BuildContext context, Widget? snapshot) => Visibility(
            visible: hostInterfaceManagementService.isHostEvaluating,
            child: HostGrading(
              gameStats: hostInterfaceManagementService.gameStats,
              qrlAnswers: hostInterfaceManagementService.responsesQRL,
            ),
          ),
        );
        break;
      case QuestionType.QRE:
      case QuestionType.QCM:
      default:
        returnedWidget = Column(
          children: [
            HistogramLegend(), Histogram()
          ],
        );
        break;
    }
    return returnedWidget;
  }

  @override
  Widget build(BuildContext context) {
    return getHostInterface();
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
          'Le jeux est terminé! voici les résultats.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        PlayersDataTable(
          isHost: true,
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
