import 'dart:async';
import 'package:flutter/material.dart';
import 'socket_service.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/constants/timer_message.dart';
import 'package:polyquiz/constants/question_type.dart';
import 'package:polyquiz/models/question_statistics.dart';
import 'package:polyquiz/models/quiz_interface.dart';

class HostInterfaceManagementService extends ChangeNotifier {
  final GameService gameService;
  final SocketService socketService = SocketService();
  final InteractiveListService interactiveListService;

  String timerText = TimerMessage.TIME_LEFT;
  bool isGameOver = false;
  bool isHostEvaluating = false;
  bool isPaused = false;
  bool isPanicMode = false;
  Map<String, int> histogramDataChangingResponses = {};
  Map<String, bool> histogramDataValue = {};
  List<Player> leftPlayers = [];
  Map<String, Map<String, dynamic>> responsesQRL = {};
  List<QuestionStatistics> gameStats = [];
  int get roomId => gameService.realGameService.roomId;

  HostInterfaceManagementService({
    required this.gameService,
    required socketService,
    required this.interactiveListService,
  }) {
    configureBaseSocketFeatures();
  }

  void configureBaseSocketFeatures() {
    reset();
    handleTimeTransition();
    handleEndQuestion();
    handleFinalTimeTransition();
    handleRefreshChoicesStats();
    handleGetInitialQuestion();
    handleGetNextQuestion();
    handleRemovedPlayer();
    handleEndQuestionAfterRemoval();
    handleEvaluationOver();
    handleRefreshActivityStats();
    handleHostPanicMode();
    handleHostTimerPause();
  }

  void handleTimeTransition() {
    socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      timerText = TimerMessage.NEXT;
      gameService.realGameService.timer = timeValue;
      if (gameService.timer == 0) {
        gameService.realGameService.inTimeTransition = false;
        resetInterface();
        socketService.sendMessage(SocketEvent.NEXT_QUESTION, gameService.realGameService.roomId);
        timerText = TimerMessage.TIME_LEFT;
      }
      notifyListeners();
    });
  }

  void handleEndQuestion() {
    socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      // gameService.audio.pause();
      // gameService.audio.currentTime = 0;
      gameService.realGameService.audioPaused = false;
      gameService.realGameService.inTimeTransition = true;
      resetInterface();
      if (gameService.question?.type == QuestionType.QCM) {
        interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers, resetPlayerStatus : false);
      } else {
        sendQrlAnswer();
        isHostEvaluating = true;
      }
      notifyListeners();
    });
  }

  void handleFinalTimeTransition() {
    socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION, (timeValue) {
      timerText = TimerMessage.RESULT_AVAILABLE_IN;
      gameService.realGameService.timer = timeValue;
      if (gameService.timer == 0 && gameService.username == 'HOST_USERNAME') {
        isGameOver = true;
        interactiveListService.isFinal = true;
        // gameService.audio.pause();
        interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers);
      }
      notifyListeners();
    });
  }

  void handleRefreshChoicesStats() {
    socketService.onMessage(SocketEvent.REFRESH_CHOICES_STATS, (choicesStatsValue) {
      histogramDataChangingResponses = createChoicesStatsMap(choicesStatsValue);
      notifyListeners();
    });
  }

  void handleGetInitialQuestion() {
    socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION, (data) async {
      final numberOfPlayers = await interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers);
      initGraph(data['question'], numberOfPlayers);
      notifyListeners();
    });
  }

  void handleGetNextQuestion() {
    socketService.onMessage(SocketEvent.GET_NEXT_QUESTION, (data) async {
      final numberOfPlayers = await interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers);
      initGraph(data['question'], numberOfPlayers);
      notifyListeners();
    });
  }

  void handleRemovedPlayer() {
    socketService.onMessage(SocketEvent.REMOVED_PLAYER, (username) {
      final playerIndex = interactiveListService.players.indexWhere((player) => player.username == username);
      if (playerIndex != -1) {
        leftPlayers.add(interactiveListService.players[playerIndex]);
        interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers, resetPlayerStatus : false);
      }
      notifyListeners();
    });
  }

  void handleEndQuestionAfterRemoval() {
    socketService.onMessage(SocketEvent.END_QUESTION_AFTER_REMOVAL, (_) {
      resetInterface();
      notifyListeners();
    });
  }

  void handleHostPanicMode() {
    socketService.onMessage(SocketEvent.PANIC_MODE, (_) {
      // if (gameService.timer > 0 && !gameService.realGameService.audioPaused) {
      //   gameService.audio.play();
      // }
      isPanicMode = true;
      notifyListeners();
    });
  }

  void handleHostTimerPause() {
    socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      // if (gameService.realGameService.audioPaused && isPanicMode) {
      //   gameService.audio.play();
      // } else if (!gameService.realGameService.audioPaused && isPanicMode) {
      //   gameService.audio.pause();
      // }
      gameService.realGameService.audioPaused = !gameService.realGameService.audioPaused;
      notifyListeners();
    });
  }

  void handleEvaluationOver() {
    socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      interactiveListService.getPlayersList(roomId, leftPlayers : leftPlayers, resetPlayerStatus : false);
      notifyListeners();
    });
  }

  void handleRefreshActivityStats() {
    socketService.onMessage(SocketEvent.REFRESH_ACTIVITY_STATS, (activityStatsValue) {
      histogramDataChangingResponses = {
        'ACTIVE': activityStatsValue[0],
        'INACTIVE': activityStatsValue[1],
      };
      notifyListeners();
    });
  }

  void resetInterface() {
    gameService.realGameService.validated = true;
    gameService.realGameService.locked = true;
  }

  void initGraph(QuizQuestion question, [int? numberOfPlayers]) {
    isHostEvaluating = false;
    histogramDataValue = {};
    histogramDataChangingResponses = {};
    if (question.type == QuestionType.QCM) {
      question.choices?.forEach((choice) {
        histogramDataValue[choice.text] = choice.isCorrect ?? false;
      });
    } else {
      histogramDataChangingResponses = {
        'ACTIVE': 0,
        'INACTIVE': numberOfPlayers ?? 0,
      };
      histogramDataValue = {
        'ACTIVE': true,
        'INACTIVE': false,
      };
    }
  }

  Map<String, int> createChoicesStatsMap(List<int> choicesStatsValue) {
    final choicesStats = <String, int>{};
    final choices = gameService.question?.choices;
    choices?.asMap().forEach((index, choice) {
      choicesStats[choice.text] = choicesStatsValue[index];
    });
    return choicesStats;
  }

  void sendQrlAnswer() {
    socketService.sendMessageWithAck(SocketEvent.GET_PLAYER_ANSWERS, gameService.realGameService.roomId, (playerAnswers) {
      responsesQRL = Map<String, Map<String, dynamic>>.from(playerAnswers);
      notifyListeners();
    });
  }

  void sendGameStats() {
    final gameStats = stringifyStats();
    socketService.sendMessage(SocketEvent.GAME_STATUS_DISTRIBUTION, {
      'roomId': gameService.realGameService.roomId,
      'stats': gameStats,
    });
  }

  String stringifyStats() {
    final stats = prepareStatsTransport();
    return stats.toString();
  }

  List<List<dynamic>> prepareStatsTransport() {
    final data = <List<dynamic>>[];
    gameStats.forEach((stats) {
      final values = stats[0].toList();
      final responses = stats[1].toList();
      data.add([values, responses, stats[2] as QuizQuestion]);
    });
    return data;
  }

  void reset() {
    timerText = TimerMessage.TIME_LEFT;
    isGameOver = false;
    histogramDataChangingResponses = {};
    histogramDataValue = {};
    leftPlayers = [];
    responsesQRL = {};
    isHostEvaluating = false;
    gameStats = [];
    isPaused = false;
    isPanicMode = false;
  }

  void sendPauseTimer() {
    isPaused = !isPaused;
    socketService.sendMessage(SocketEvent.PAUSE_TIMER, gameService.realGameService.roomId);
  }

  void startPanicMode() {
    socketService.sendMessage(SocketEvent.PANIC_MODE, {
      'roomId': gameService.realGameService.roomId,
      'timer': gameService.realGameService.timer,
    });
    isPanicMode = true;
  }

  void requestNextQuestion() {
    isPanicMode = false;
    gameService.realGameService.validated = false;
    gameService.realGameService.locked = false;
    socketService.sendMessage(SocketEvent.START_TRANSITION, gameService.realGameService.roomId);
  }

  void handleLastQuestion() {
    sendGameStats();
    socketService.sendMessage(SocketEvent.SHOW_RESULT, gameService.realGameService.roomId);
  }
}