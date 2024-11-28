import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/fancyAppBar.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/host_interface_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qre_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qrl_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_info_widget.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_notice.dart';
import 'package:polyquiz/widgets/game_widgets/quit_btn.dart';
import 'package:polyquiz/widgets/game_widgets/timer_widget.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/widgets/game_widgets/host_widgets/players_data_table_widget.dart';
import 'package:polyquiz/widgets/game_widgets/question_result.dart';
import '../models/user.dart';
import 'package:polyquiz/widgets/observer_widgets/observer_counter.dart';
import 'package:polyquiz/widgets/observer_widgets/observation_selector.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<GamePage> {
  late bool isHost;
  bool isQcm = false; // Il faudra remplacer par un enum par la suite
  bool isGrading = true;
  int time = 10;
  int questionNum = 1;
  int questionPts = 50;
  String questionTxt = "Question par defaut ?";
  String _message = 'null';
  String get message => _message;
  void set message(String value) => _message = value;
  bool isQuitBtn = false;
  GameService _gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();
  GameInterfaceManagementService _gameInterfaceManagementService =
      GameInterfaceManagementService();
  ThemeService themeService = ThemeService.instance;
  final TranslationService transService = TranslationService.instance;
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get timerText => gameText['TIMER_TEXT'];

  @override
  void initState() {
    super.initState();
    message = gameText['PLAYER_QRL_INTERFACE']['AWAITING_EVALUATION'];
    this.isHost = this._gameService.realGameService.username == 'host';
    print(
        'isAlreadyInit interactive service: ${_interactiveListService.isAlreadyInit}');
    if (_socketService.isSocketAlive() &&
        !_interactiveListService.isAlreadyInit) {
      _socketService.clearAllListeners();
      _cleanupSocketListeners();
    }
    if (this._gameService.isObserverMode) {
      final game = ObservationService.instance.gameConfigs;
      this._gameService.init(game!.room.toString(), true);
      this._gameService.realGameService.username = 'host';
      ObservationService.instance.observeGame(game, context);
    }
    if (_socketService.isSocketAlive()) {
      if (!isHost) {
        this._gameInterfaceManagementService.gameService.isOfflineMode = false;
        this
            ._gameInterfaceManagementService
            .setUp(this._gameService.realGameService.roomId.toString());
      }
    }
    ObservationService.instance.callback = (bool value) {
      setState(() {
        this.isHost = value;
      });
    };
  }

  Future<void> _cleanupSocketListeners() async {
    while (_socketService.getListenerCount() != 0) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    _interactiveListService.configureBaseSocketFeatures();
  }

  @override
  void dispose() {
    if (_gameService.isQuitBtn) {
      isHost = false;
      isQcm = false;
      isGrading = true;
      time = 10;
      questionNum = 1;
      questionPts = 50;
      questionTxt = "Question par defaut ?";
      message = gameText['PLAYER_QRL_INTERFACE']['AWAITING_EVALUATION'];
      isQuitBtn = false;
    }
    super.dispose();
  }

  Widget getPlayerQuestion() {
    Widget? questionWidget;
    switch (_gameInterfaceManagementService.gameService.question?.type) {
      case QuestionType.QCM:
        questionWidget = Container(height: 500, child: PlayerQcm());
        break;
      case QuestionType.QRL:
        questionWidget = PlayerQrl();
        break;
      case QuestionType.QRE:
        questionWidget = PlayerQreWidget();
        break;
      default:
        questionWidget = Text("Unimplemented Question Type");
        break;
    }
    return Visibility(
        visible: !this._gameService.realGameService.isHostEvaluating,
        child: questionWidget
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return Obx(() {
        //NE PAS DELETE LA LIGNE EN BAS JE SAIS QUE TON IDE TE DIS QUE C'EST PAS UTILISÉ
        // MAIS IL VOIT PAS QUE OBX LE SCRUTE!!!! (il y a qqn qui delete ces fonctions)
        //-MAXIME
        var observationEnablerDONOTDELETE = TranslationService.instance.languageValue.value;

        return Scaffold(
          appBar: FancyAppBar(context: context, isGamePage: true, isObserver: this._gameService.isObserverMode,),
          backgroundColor: themeService.mainBackground.value,
          body: Container(
            color: themeService.mainBackground.value,
            child: Stack(children: [
              ListView(children: [
                Visibility(
                    visible: isHost,
                    child: HostInterface(
                        interactiveListService: _interactiveListService,
                        gameInterfaceManagementService:
                        _gameInterfaceManagementService))
              ]),
              Positioned(bottom: 20, left: 20, child: ChatPopup())
            ]),
          ),
        );
      });
    } else {
      return Obx(() {


      //DO NOT DELETE (ca dit au obx que son rendu depend de cette variable
      Language ObxObservator = transService.languageValue.value;

      return Container(
          color: themeService.mainBackground.value,
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
                          gameText["LOADING_QUESTIONS"],
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
                        if (_gameInterfaceManagementService.isResultPage) {
                          return Scaffold(
                            appBar: FancyAppBar(context: context, isGamePage: true, isObserver: this._gameService.isObserverMode,),
                            backgroundColor: themeService.mainBackground.value,
                            body: ListView(
                              children: [
                                ResultPage(
                                  gameService: _gameInterfaceManagementService
                                      .gameService,
                                  interactiveListService:
                                  _interactiveListService,
                                  gameInterfaceManagementService:
                                  _gameInterfaceManagementService,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Scaffold(
                            appBar: FancyAppBar(context: context, isGamePage: true, isObserver: this._gameService.isObserverMode,),
                            backgroundColor: themeService.mainBackground.value,
                            body: Stack(children: [
                              ListView(shrinkWrap: true, children: [
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
                                              time:
                                              _gameInterfaceManagementService
                                                  .gameService.timer,
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.center,
                                              child: QuestionInfoWidget(
                                                  questionNum:
                                                  _gameInterfaceManagementService
                                                      .gameService
                                                      .questionNumber,
                                                  questionPts:
                                                  _gameInterfaceManagementService
                                                      .gameService
                                                      .question?.points ?? 0,
                                                  questionText:
                                                  _gameInterfaceManagementService
                                                      .gameService
                                                      .question?.text ?? ''),
                                            ),
                                          if (!this._gameService.isObserverMode) Expanded(
                                            child: Container(
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.all(5.0),
                                              padding: EdgeInsets.all(10.0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: themeService
                                                          .mainAccent.value)),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${gameText['CURRENT_POINTS']}: ${_gameInterfaceManagementService.playerScore}',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: themeService
                                                            .mainAccent.value),
                                                  ),
                                                  _gameInterfaceManagementService
                                                      .isBonus
                                                      ? Text(
                                                      gameText[
                                                      'BONUS_RECEIVED_FEEDBACK'],
                                                      style: TextStyle(
                                                          color: themeService
                                                              .mainAccent
                                                              .value))
                                                      : SizedBox()
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      if (getImageWidgetFromQuestion() != null)
                                        getImageWidgetFromQuestion()!,
                                      getPlayerQuestion(),
                                      Visibility(
                                        visible: _gameInterfaceManagementService
                                            .gameService
                                            .realGameService
                                            .isHostEvaluating,
                                        child: PlayerNotice(
                                          message: message,
                                          gameInterfaceManagementService:
                                          _gameInterfaceManagementService,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [getButtons()],
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                              Positioned(
                                  bottom: 0, left: 20, child: ChatPopup())
                            ]),
                          );
                        }
                      });
                }
              })
      );}
        );
    }
  }

  Widget? getImageWidgetFromQuestion() {
    String? imageUrl = this._gameService.realGameService.question?.imageUrl;
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

  Widget getButtons() {
    final isValidateButtonActive =
        !this._gameService.realGameService.isHostEvaluating &&
            this._gameService.realGameService.isValidateActive;

    final validateButtonStyle = TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: FontWeight.normal),
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: isValidateButtonActive ? Colors.blueAccent : Colors.grey,
    );

    return Row(
      children: <Widget>[
        if (!this._gameService.isObserverMode) AnimatedBuilder(
          animation: this._gameService.realGameService,
          builder: (BuildContext context, Widget? snapshot) => TextButton(
              onPressed: isValidateButtonActive ? onValidate : null,
              style: validateButtonStyle,
              child: Text(
                gameText['VALIDATE_BUTTON'],
                style: TextStyle(
                  color: themeService.secondaryAccent.value,
                  fontSize: 20,
                ),
              )),
        ),
        if (!this._gameService.isObserverMode) SizedBox(width: 100.0),
        QuitBtn(
          isHost: false,
          roomId: this._gameService.realGameService.roomId,
          gameService: _gameService,
          interactiveListService: _interactiveListService,
          gameInterfaceManagementService: _gameInterfaceManagementService,
        )
      ],
    );
  }

  void onValidate() {
    _gameService.realGameService.isValidateActive = false;
    if (_gameInterfaceManagementService.gameService.question?.type ==
        QuestionType.QRL) {
      // _gameInterfaceManagementService
      //     .gameService.realGameService.isHostEvaluating = true;
    }
    _gameInterfaceManagementService.gameService.sendAnswer();
  }
}

class ResultPage extends StatelessWidget {
  final GameService gameService;
  final InteractiveListService? interactiveListService;
  final GameInterfaceManagementService? gameInterfaceManagementService;
  final ThemeService _themeService = ThemeService.instance;
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  final TranslationService transService = TranslationService.instance;
  ResultPage({
    required this.gameService,
    this.interactiveListService,
    this.gameInterfaceManagementService,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      //DO NOT DELETE (ca dit au obx que son rendu depend de cette variable
      Language ObxObservator = transService.languageValue.value;

      return Container(
        color: _themeService.mainBackground.value,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameText['GAME_FINISHED'] + " , " + gameText["PLAYERS_RESULT"],
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _themeService.mainAccent.value),
            ),
            PlayersDataTable(
              isHost: false,
            ),
            StatisticZone(
                gameStats: this.gameInterfaceManagementService!.gameStats),
            QuitBtn(
              isHost: false,
              roomId: gameService.realGameService.roomId,
              gameService: gameService,
              interactiveListService: interactiveListService,
              gameInterfaceManagementService: gameInterfaceManagementService,
            ),
          ],
        ),
      );
    });
  }
}
