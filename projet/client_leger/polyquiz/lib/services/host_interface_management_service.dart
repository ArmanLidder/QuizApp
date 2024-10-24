import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'dart:convert';

class HostInterfaceManagementService {
  static final HostInterfaceManagementService _instance =
      HostInterfaceManagementService._internal();

  HostInterfaceManagementService._internal();

  factory HostInterfaceManagementService() {
    return _instance;
  }

  String timerText = 'Temps restant';
  bool isGameOver = false;
  Map<String, int> histogramDataChangingResponses = {};
  Map<String, bool> histogramDataValue = {};
  List<Player> leftPlayers = [];
  Map<String, ResponseData> responsesQRL = {};
  bool isHostEvaluating = false;
  List<QuestionStatistics> gameStats = [];
  bool isPaused = false;
  bool isPanicMode = false;

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

  configureBaseSocketFeatures() {
    this.reset();
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
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      this.timerText = 'Prochaine question dans: ';
      this.gameService.realGameService.timer = timeValue;
      if (this.gameService.realGameService.timer == 0) {
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

      if (this.gameService.question?.type == QuestionType.QCM) {
        this._interactiveListService.getPlayersList(roomId,
            leftPlayers: leftPlayers, resetPlayerStatus: false);
      } else {
        this.sendQrlAnswer();
        this.isHostEvaluating = true;
      }
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
        this
            ._interactiveListService
            .getPlayersList(this.roomId, leftPlayers: leftPlayers);
      }
    });
  }

  void handleRefreshChoicesStats() {
    this._socketService.onMessage(SocketEvent.REFRESH_CHOICES_STATS,
        (choicesStatsValue) {
      this.histogramDataChangingResponses =
          createChoicesStatsMap(List<num>.from(choicesStatsValue));
    });
  }

  void handleGetInitialQuestion() {
    this._socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION,
        (data) async {
      final numberOfPlayers = await _interactiveListService
          .getPlayersList(roomId, leftPlayers: leftPlayers);
      initGraph(QuizQuestion.fromJson(data['question']), numberOfPlayers);
    });
  }

  void handleGetNextQuestion() {
    this._socketService.onMessage(SocketEvent.GET_NEXT_QUESTION, (data) async {
      final numberOfPlayers = await this
          ._interactiveListService
          .getPlayersList(roomId, leftPlayers: leftPlayers);
      initGraph(QuizQuestion.fromJson(data['question']), numberOfPlayers);
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
  }

  void initGraph(QuizQuestion question, int numberOfPlayers) {
    //todo voir avec la maniere dont l'histogramme est fait
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
      this.responsesQRL =
          Map<String, ResponseData>.from(jsonDecode(playerAnswers));
    });
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
      //todo
      final values = stats.responsesValues;
      final responses = stats.responsesNumber;
      data.add(TransportStats(values.entries.toList(),
          responses.entries.toList(), stats.question as QuizQuestion));
    });
    return data;
  }

  void reset() {
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
  }
}

class ResponseData {
  final String answers;
  final int time;

  ResponseData(this.answers, this.time);
}
