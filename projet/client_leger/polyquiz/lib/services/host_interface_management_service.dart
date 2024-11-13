import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/constants/timer_message.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'dart:convert';

class HostInterfaceManagementService extends ChangeNotifier {
  static final HostInterfaceManagementService _instance =
      HostInterfaceManagementService._internal();

  HostInterfaceManagementService._internal();

  factory HostInterfaceManagementService() {
    return _instance;
  }

  String timerText = TimerMessage.TIME_LEFT;
  bool isGameOver = false;
  Map<String, int> histogramDataChangingResponses = {};
  Map<String, bool> histogramDataValue = {};
  List<Player> leftPlayers = [];
  Map<String, ResponseData> responsesQRL = {};
  bool isHostEvaluating = false;
  List<QuestionStatistics> gameStats = [];
  bool isPaused = false;
  bool isPanicMode = false;
  bool isAlreadyInit = false;
  bool isAlreadyCalled = false;
  bool NextQuestionBtnDisabled = true;

  GameService gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();

  int get roomId {
    return gameService.realGameService.roomId;
  }

  void sendPauseTimer() {
    this.isPaused = !this.isPaused;
    this._socketService.sendMessage(SocketEvent.PAUSE_TIMER, this.roomId);
  }

  void startPanicMode() {
    this._socketService.sendMessage(SocketEvent.PANIC_MODE, {
      'roomId': this.roomId,
      'timer': this.gameService.realGameService.timer,
    });
    this.isPanicMode = true;
  }

  void saveStats() {
    QuizQuestion? question = this.gameService.realGameService.question;
    if (question != null) {
      QuestionStatistics savedStats = QuestionStatistics(
          this.histogramDataValue,
          this.histogramDataChangingResponses,
          question);
      if (question.type != QuestionType.QRL) {
        this.gameStats.add(savedStats);
        notifyListeners();
      }
    }
  }

  void requestNextQuestion() {
    this.isPanicMode = false;
    this.gameService.realGameService.validated = false;
    this.gameService.realGameService.locked = false;
    this._socketService.sendMessage(SocketEvent.START_TRANSITION, this.roomId);
  }

  void handleLastQuestion() {
    sendGameStats();
    this._socketService.sendMessage(SocketEvent.SHOW_RESULT, this.roomId);
  }

  configureBaseSocketFeatures(BuildContext context) {
    this.reset(context);
    this.handleTimeTransition();
    this.handleEndQuestion();
    this.handleFinalTimeTransition();
    this.handleRefreshChoicesStats();
    this.handleGetInitialQuestion();
    this.handleGetNextQuestion();
    this.handleRemovedPlayer();
    this.handleEndQuestionAfterRemoval();
    this.handleEvaluationOver();
    this.handleRefreshActivityStats();
    this.handleHostPanicMode();
    this.handleHostTimerPause();
    isAlreadyInit = true;
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      this.timerText = 'Prochaine question dans: ';
      this.gameService.realGameService.timer = timeValue;
      notifyListeners();
      if (this.gameService.realGameService.timer == 0) {
        print('TIMER GOT TO 0');
        this.gameService.realGameService.inTimeTransition = false;
        this.resetInterface();
        this._socketService.sendMessage(
            SocketEvent.NEXT_QUESTION, this.gameService.realGameService.roomId);
        this.timerText = 'Temps restant: ';
      }
    });
  }

  void handleEndQuestion() {
    this._socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.gameService.realGameService.inTimeTransition = true;
      this.resetInterface();

      QuestionType? type = this.gameService.question?.type ?? null;
      switch (type) {
        case QuestionType.QRL:
          this.sendQrlAnswer();
          print('CALLED 1');
          this.isHostEvaluating = true;
          this.NextQuestionBtnDisabled = false;
          notifyListeners();
          break;
        case QuestionType.QRE:
        case QuestionType.QCM:
        default:
          print('CALLED 1');
          this._interactiveListService.getPlayersList(roomId,
              leftPlayers: leftPlayers, resetPlayerStatus: false);
          this.NextQuestionBtnDisabled = false;
          break;
      }
      //
      // if (this.gameService.question?.type == QuestionType.QCM) {
      //   print('CALLED 1');
      //   this._interactiveListService.getPlayersList(roomId, leftPlayers: leftPlayers, resetPlayerStatus: false);
      // } else {
      //   this.sendQrlAnswer();
      //   this.isHostEvaluating = true;
      //   notifyListeners();
      // }
    });
  }

  void handleFinalTimeTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION,
        (timeValue) {
      this.timerText = 'Résultats disponibles dans: ';
      this.gameService.realGameService.timer = timeValue;

      if (this.gameService.timer == 0 && this.gameService.username == 'host') {
        this.isGameOver = true;
        this._interactiveListService.isFinal = true;
        this.gameService.audio.pause();
        print('CALLED 2');
        this
            ._interactiveListService
            .getPlayersList(this.roomId, leftPlayers: leftPlayers);
        this._socketService.sendMessage(SocketEvent.SAVE_FINAL_GAME_STATS,
            this.gameService.realGameService.roomId);
      }
    });
  }

  void handleRefreshChoicesStats() {
    this._socketService.onMessage(SocketEvent.REFRESH_CHOICES_STATS,
        (choicesStatsValue) {
      this.histogramDataChangingResponses =
          createChoicesStatsMap(List<num>.from(choicesStatsValue));
      notifyListeners();
    });
  }

  void handleGetInitialQuestion() {
    this._socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION,
        (data) async {
      // if (isAlreadyCalled)
      //   return;
      print('CALLED 3');
      final numberOfPlayers = await _interactiveListService
          .getPlayersList(roomId, leftPlayers: leftPlayers);
      initGraph(QuizQuestion.fromJson(data['question']), numberOfPlayers);
      // isAlreadyCalled = true;
    });
  }

  void handleGetNextQuestion() {
    this._socketService.onMessage(SocketEvent.GET_NEXT_QUESTION, (data) async {
      this.histogramDataChangingResponses.clear();
      this.histogramDataValue.clear();
      notifyListeners();
      print('CALLED 4');
      final numberOfPlayers = await this
          ._interactiveListService
          .getPlayersList(roomId, leftPlayers: leftPlayers);
      initGraph(QuizQuestion.fromJson(data['question']), numberOfPlayers);
      this.NextQuestionBtnDisabled = true;
    });
  }

  void handleRemovedPlayer() {
    this._socketService.onMessage(SocketEvent.REMOVED_PLAYER, (username) {
      int playerIndex = this
          ._interactiveListService
          .players
          .indexWhere((player) => player.username == username);
      if (playerIndex != -1) {
        this.leftPlayers.add(this._interactiveListService.players[playerIndex]);
        print('CALLED 5');
        this._interactiveListService.getPlayersList(roomId,
            leftPlayers: leftPlayers, resetPlayerStatus: false);
      }
    });
  }

  void handleEndQuestionAfterRemoval() {
    this._socketService.onMessage(SocketEvent.END_QUESTION_AFTER_REMOVAL, (_) {
      resetInterface();
    });
  }

  void handleHostPanicMode() {
    this._socketService.onMessage(SocketEvent.PANIC_MODE, (_) {
      if (this.gameService.timer > 0 &&
          !this.gameService.realGameService.audioPaused) {
        this.gameService.audio.play(AssetSource('music.mp3'));
      }
      this.isPanicMode = true;
    });
  }

  void handleHostTimerPause() {
    this._socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      if (this.gameService.realGameService.audioPaused && this.isPanicMode) {
        this.gameService.audio.play(AssetSource('music.mp3'));
      } else if (!this.gameService.realGameService.audioPaused &&
          this.isPanicMode) {
        this.gameService.audio.pause();
      }
      this.gameService.realGameService.audioPaused =
          !this.gameService.realGameService.audioPaused;
    });
  }

  void handleEvaluationOver() {
    this._socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      print('CALLED 6');
      _interactiveListService.getPlayersList(roomId,
          leftPlayers: leftPlayers, resetPlayerStatus: false);
    });
  }

  void handleRefreshActivityStats() {
    this._socketService.onMessage(SocketEvent.REFRESH_ACTIVITY_STATS,
        (activityStatsValue) {
      histogramDataChangingResponses = {
        'Actif': activityStatsValue[0],
        'Inactif': activityStatsValue[1],
      };
    });
  }

  void resetInterface() {
    this.gameService.realGameService.validated = true;
    this.gameService.realGameService.locked = true;
    notifyListeners();
  }

  void initGraph(QuizQuestion question, int numberOfPlayers) {
    print('question in init graph');
    print(question);
    this.isHostEvaluating = false;
    if (question.type == QuestionType.QCM && question.choices != null) {
      print('INIT GRAPH GOT INTO THE IF');
      for (QuizChoice choice in question.choices!) {
        this
            .histogramDataValue
            .addEntries(<String, bool>{choice.text: choice.isCorrect!}.entries);
      }
    }
    notifyListeners();
  }

  Map<String, int> createChoicesStatsMap(List<num> choicesStatsValue) {
    final choicesStats = <String, int>{};
    final choices = this.gameService.question?.choices;

    choices?.asMap().forEach((index, choice) {
      choicesStats[choice.text] = choicesStatsValue[index].toInt();
    });

    return choicesStats;
  }

  void sendQrlAnswer() {
    this._socketService.sendMessageWithAck(
        SocketEvent.GET_PLAYER_ANSWERS, this.gameService.realGameService.roomId,
        (playerAnswers) {
      List<dynamic> decodedAnswers = jsonDecode(playerAnswers);
      this.responsesQRL = transformIntoResponsesQrl(decodedAnswers);
    });
    notifyListeners();
  }

  void sendGameStats() {
    final gameStats = stringifyStats();
    this._socketService.sendMessage(SocketEvent.GAME_STATUS_DISTRIBUTION, {
      'roomId': this.gameService.realGameService.roomId,
      'stats': gameStats,
    });
  }

  String stringifyStats() {
    final stats = this.prepareStatsTransport();
    return stats.toString();
  }

  TransportStatsFormat prepareStatsTransport() {
    final TransportStatsFormat data = [];
    this.gameStats.forEach((stats) {
      final values = stats.responsesValues;
      final responses = stats.responsesNumber;
      data.add(TransportStats(values.entries.toList(),
          responses.entries.toList(), stats.question as QuizQuestion));
    });
    return data;
  }

  void reset(BuildContext context) {
    this.timerText = 'Temps restant: ';
    this.isGameOver = false;
    this.histogramDataChangingResponses.clear();
    this.histogramDataValue.clear();
    this.leftPlayers.clear();
    this.responsesQRL.clear();
    this.isHostEvaluating = false;
    this.gameStats.clear();
    this.isPaused = false;
    this.isPanicMode = false;
    this.isAlreadyInit = false;
    this.isAlreadyCalled = false;
    this.NextQuestionBtnDisabled = true;
    notifyListeners();
  }

  Map<String, ResponseData> transformIntoResponsesQrl(
      List<dynamic> playerAnswers) {
    Map<String, ResponseData> map = {};

    for (var answer in playerAnswers) {
      String key = answer[0];
      ResponseData value =
          ResponseData(answer[1]['answers'], answer[1]['time']);
      map[key] = value;
    }
    return map;
  }
}

class ResponseData {
  final String answers;
  final int time;

  ResponseData(this.answers, this.time);
}
