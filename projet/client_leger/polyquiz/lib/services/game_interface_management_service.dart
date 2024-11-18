import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/score.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/translationService.dart';

class GameInterfaceManagementService extends ChangeNotifier {
  static final GameInterfaceManagementService _instance =
      GameInterfaceManagementService._internal();

  GameInterfaceManagementService._internal();
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get timerTransText => gameText['TIMER_TEXT'];

  factory GameInterfaceManagementService() {
    return _instance;
  }

  bool isBonus = false;
  bool isGameOver = false;
  bool _qcmEnabled = true;
  int playerScore = 0;
  List<Player> players = [];
  bool inPanicMode = false;
  List<dynamic> gameStats = []; // Type a revoir
  String get timerText => timerTransText[isDefaultTimerMessage ? 'TIME_LEFT' : 'FINAL_RESULT'];
  bool isDefaultTimerMessage = true;
  bool isNotified = false;
  bool isResultPage = false;
  GameService gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();

  void setUp(String pathId) {
    if (this.gameService.isOfflineMode) {
      if (this._socketService.isSocketAlive()) {
        this._socketService.disconnect();
      }
    }
    if (this._socketService.isSocketAlive()) {
      this.configureBaseSocketFeatures();
    }
    this.gameService.init(pathId);
  }

  void reset() {
    this.players = [];
    this.isGameOver = false;
    this.isBonus = false;
    this.playerScore = 0;
    this.gameStats = [];
    this.isDefaultTimerMessage = true;
    this.inPanicMode = false;
    this._qcmEnabled = true;
    this.isResultPage = false;
  }

  void configureBaseSocketFeatures() {
    this.handleEndQuestion();
    this.handleEvaluationOver();
    this.handleTimeTransition();
    this.handleFinalTimeTransition();
    this.handleRemovedFromGame();
    this.handlePanicMode();
    this.handlePauseTimer();
    this.handleGameStatusDistribution();
  }

  void resetData() {
    this.gameService.audio.pause();
    this.gameService.audio.seek(Duration.zero);
    this.gameService.realGameService.audioPaused = false;
    this.inPanicMode = false;
    this.gameService.realGameService.locked = false;
    this.gameService.realGameService.validated = false;
    this.isBonus = false;
    this.isDefaultTimerMessage = true;
  }

  void handleEndQuestion() {
    this._socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.inPanicMode = false;
      if (this.gameService.question?.type == QuestionType.QCM) {
        this.getScore();
      } else {
        this.gameService.qrlAnswer = '';
        this.gameService.realGameService.validated = true;
      }
      this.gameService.realGameService.isNotified = false;
      this.gameService.realGameService.isValidateActive = false;
      notifyListeners();
    });
  }

  void handleEvaluationOver() {
    this._socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      this.getScore();
      notifyListeners();
    });
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      this.gameService.realGameService.timer = timeValue;
      if (this.gameService.timer == 0) {
        this.resetData();
      }
      notifyListeners();
    });
  }

  void handleFinalTimeTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION,
        (timeValue) {
      //todo code pour afficher la transition aux resultats finaux
      this.gameService.realGameService.timer = timeValue;
      this.isDefaultTimerMessage = false;
      if (this.gameService.timer == 0) {
        this.isGameOver = true;
        this._interactiveListService.isFinal = true;
        final numberOfPlayers = this._interactiveListService.getPlayersList(this.gameService.realGameService.roomId);
        this.isResultPage = true;
      }
      notifyListeners();
    });
  }

  void handleRemovedFromGame() {
    this._socketService.onMessage(SocketEvent.REMOVED_FROM_GAME, (_) {
      this.gameService.destroy();
      this.reset();
      this._interactiveListService.reset();
      this._globalNavigationService.navigateTo('/home');
    });
  }

  void handlePanicMode() {
    this._socketService.onMessage(SocketEvent.PANIC_MODE, (_) {
      if (this.gameService.timer > 0 &&
          !this.gameService.realGameService.audioPaused) {
        this.gameService.audio.play(AssetSource('music.mp3'));
      }
      this.inPanicMode = true;
      notifyListeners();
    });
  }

  void handlePauseTimer() {
    this._socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      if (this.gameService.realGameService.audioPaused && this.inPanicMode) {
        this.gameService.audio.play(AssetSource('music.mp3'));
      } else if (!this.gameService.realGameService.audioPaused &&
          this.inPanicMode) {
        this.gameService.audio.pause();
      }
      this.gameService.realGameService.audioPaused =
          !this.gameService.realGameService.audioPaused;
      notifyListeners();
    });
  }

  void handleGameStatusDistribution() {
    this._socketService.onMessage(SocketEvent.GAME_STATUS_DISTRIBUTION,
        (gameStats) {
      try {
        this.unpackStats(this.parseGameStats(gameStats));
        notifyListeners();
      } catch (e) {
        print('Error in handleGameStatusDistribution: $e');
      }
    });
  }

  // parseGameStats(stringifyStats) {
  //   return stringifyStats;
  // }
  
  TransportStatsFormat parseGameStats(dynamic stringifyStats) {
    final List<dynamic> jsonList = jsonDecode(stringifyStats);
    return jsonList.map((json) => TransportStats.fromJson(json)).toList();
  }

  void unpackStats(TransportStatsFormat stats) {
    stats.forEach((stat) {
      final values = new Map<String, bool>();
      values.addEntries(stat.values);
      final responses = new Map<String, num>();
      responses.addEntries(stat.responses);
      this.gameStats.add([values, responses, stat.question]);
      // print(this.gameStats);
    });
  }

  void getScore() {
    if (this.gameService.realGameService.username != 'host') {
      this._socketService.sendMessageWithAck(
        SocketEvent.GET_SCORE,
        {
          'roomId': this.gameService.realGameService.roomId,
          'username': this.gameService.realGameService.username,
        },
        (dynamic response) {
          final score = Score.fromJson(response);
          this.gameService.realGameService.validated = true;
          this.updateScore(score.points);
          this.isBonus = score.isBonus;
        },
      );
    }
  }

  void updateScore(int score) {
    final oldScore = this.playerScore;
    this.playerScore = score;
    if (this.gameService.question?.type == QuestionType.QRL) {
      this.gameService.lastQrlScore = (((playerScore - oldScore) /
                  (gameService.realGameService.question?.points ?? 0)) *
              100)
          .toInt();

      print("I am Here 444444");
      print(this.gameService.lastQrlScore);
    }
  }

  void changeQcmEnabled(bool value) {
    this._qcmEnabled = value;
    notifyListeners();
  }

  bool getQcmEnabled() {
    return this._qcmEnabled;
  }
}

class Player {
  final String username;
  final int points;

  Player({required this.username, required this.points});
}
