import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/histogram_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_grading_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_legend_widget.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_result.dart';
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
          } else if (hostInterfaceManagementService.isResultPage) {
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
                PlayersDataTableLegend(),
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
  final ThemeService _themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  Map get gameText => text['GAME_INTERFACE'];

  HostHeader({
    required this.isLastButton,
    required this.onNextQuestion,
    required this.gameService,
    required this.hostInterfaceManagementService,
    this.interactiveListService,
    this.gameInterfaceManagementService,
  });

  Widget? getImageWidgetFromQuestion(BuildContext context) {
    String? imageUrl = this.gameService.realGameService.question?.imageUrl;
    if (imageUrl == null) return null;
    return Center(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.25,
      // height: MediaQuery.of(context).size.height * 0.25,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    ));
  }

  Widget? getQREAnswer() {
    final currentQuestion = this.gameService.realGameService.question;
    if (currentQuestion == null ||
        this.gameService.realGameService.question?.type != QuestionType.QRE)
      return null;
    return Text(
      "✅ : ${currentQuestion.answer} ± ${currentQuestion.margin}",
      style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: _themeService.mainAccent.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validateButtonStyle = TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: FontWeight.normal,
      color: this.hostInterfaceManagementService.NextQuestionBtnDisabled
          ? Colors.white
          : _themeService.secondaryAccent.value,),
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor:
          this.hostInterfaceManagementService.NextQuestionBtnDisabled
              ? Colors.grey
              : _themeService.secondaryBackground.value,
    );
    return Obx(() {
      //NE PAS DELETE LA LIGNE EN BAS JE SAIS QUE TON IDE TE DIS QUE C'EST PAS UTILISÉ
      // MAIS IL VOIT PAS QUE OBX LE SCRUTE!!!! (il y a qqn qui delete ces fonctions)
      //-MAXIME
      var observationEnablerDONOTDELETE = TranslationService.instance.languageValue.value;
      return Stack(children: [
        Column(
          children: [
            Row(
              children: [
                TimerWidget(
                  isHost: true,
                  timeTxt: TranslationService.instance.text['GAME_INTERFACE']['TIMER_TEXT']['TIME_LEFT'],
                  time: gameService.realGameService.timer,
                  hostInterfaceManagementService: hostInterfaceManagementService,
                )
              ],
            ),
            if (getQREAnswer() != null) getQREAnswer()!,
            if (getImageWidgetFromQuestion(context) != null)
              getImageWidgetFromQuestion(context)!
            else
              SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                TextButton(
                  onPressed:
                  this.hostInterfaceManagementService.NextQuestionBtnDisabled
                      ? null
                      : onNextQuestion,
                  child: Text(
                    gameService.realGameService.isLast
                        ? gameText['SHOW_RESULT']
                        : gameText['NEXT_QUESTION'],
                    style: TextStyle(
                        color: this.hostInterfaceManagementService.NextQuestionBtnDisabled
                            ? Colors.white
                            : _themeService.secondaryAccent.value, fontSize: 20),
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
    });
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
          builder: (context, child) {
            return Column(
              children: [
                Visibility(
                  visible: hostInterfaceManagementService.isHostEvaluating,
                  child: HostGrading(
                    gameStats: hostInterfaceManagementService.gameStats,
                    qrlAnswers: hostInterfaceManagementService.responsesQRL,
                  ),
                ),
                HistogramLegend(),
                Histogram(),
              ],
            );
          },
        );
        // returnedWidget = Column(
        //     children: [
        //       HistogramLegend(), Histogram()
        //     ],
        // );
        break;
      case QuestionType.QRE:
      case QuestionType.QCM:
      default:
        returnedWidget = Column(
          children: [HistogramLegend(), Histogram()],
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
  ThemeService _themeService = ThemeService.instance;

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
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _themeService.mainAccent.value),
        ),
        PlayersDataTableLegend(),
        PlayersDataTable(
          isHost: true,
        ),
        StatisticZone(gameStats: this.hostInterfaceManagementService.gameStats),
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
