import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/score.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class GameInterfaceManagementService {
  static final GameInterfaceManagementService _instance =
      GameInterfaceManagementService._internal();

  GameInterfaceManagementService._internal();

  factory GameInterfaceManagementService() {
    return _instance;
  }

  bool isBonus = false;
  bool isGameOver = false;
  int playerScore = 0;
  List<Player> players = [];
  bool inPanicMode = false;
  List<dynamic> gameStats = []; // Type a revoir

  GameService _gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();
  GlobalNavigationService _globalNavigationService = GlobalNavigationService();

  void setUp(String pathId) {
    if (this._gameService.isOfflineMode) {
      if (this._socketService.isSocketAlive()) {
        this._socketService.disconnect();
      }
    }
    if (this._socketService.isSocketAlive()) {
      this.configureBaseSocketFeatures();
    }
    this._gameService.init(pathId);
  }

  void reset() {
    this.players = [];
    this.isGameOver = false;
    this.isBonus = false;
    this.playerScore = 0;
    this.gameStats = [];
    this.inPanicMode = false;
  }

  void configureBaseSocketFeatures() {}

  void resetData() {
    this._gameService.audio.pause();
    this._gameService.audio.seek(Duration.zero);
    this._gameService.realGameService.audioPaused = false;
    this.inPanicMode = false;
    this._gameService.realGameService.locked = false;
    this._gameService.realGameService.validated = false;
    this.isBonus = false;
  }

  void handleEndQuestion() {
    this._socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      this._gameService.audio.pause();
      this._gameService.audio.seek(Duration.zero);
      this._gameService.realGameService.audioPaused = false;
      this.inPanicMode = false;
      if (this._gameService.question?.type == QuestionType.QCM) {
        this.getScore();
      } else {
        this._gameService.qrlAnswer = '';
        this._gameService.realGameService.validated = true;
      }
    });
  }

  void handleEvaluationOver() {
    this._socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      this.getScore();
    });
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      this._gameService.realGameService.timer = timeValue;
      if (this._gameService.timer == 0) {
        this.resetData();
      }
    });
  }

  void handleFinalTimeTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION,
        (timeValue) {
      //todo code pour afficher la transition aux resultats finaux
      this._gameService.realGameService.timer = timeValue;
      if (this._gameService.timer == 0) {
        this.isGameOver = true;
        this._interactiveListService.isFinal = true;
        this
            ._interactiveListService
            .getPlayersList(this._gameService.realGameService.roomId);
      }
    });
  }

  void handleRemovedFromGame() {
    this._socketService.onMessage(SocketEvent.REMOVED_FROM_GAME, (_) {
      this._globalNavigationService.navigateTo('/');
    });
  }

  void handlePanicMode() {
    this._socketService.onMessage(SocketEvent.PANIC_MODE, (_) {
      if (this._gameService.timer > 0 &&
          !this._gameService.realGameService.audioPaused) {
        this._gameService.audio.play(AssetSource('music.mp3'));
      }
      this.inPanicMode = true;
    });
  }

  void handlePauseTimer() {
    this._socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      if (this._gameService.realGameService.audioPaused && this.inPanicMode) {
        this._gameService.audio.play(AssetSource('music.mp3'));
      } else if (!this._gameService.realGameService.audioPaused &&
          this.inPanicMode) {
        this._gameService.audio.pause();
      }
      this._gameService.realGameService.audioPaused =
          !this._gameService.realGameService.audioPaused;
    });
  }

  void handleGameStatusDistribution() {
    this._socketService.onMessage(SocketEvent.GAME_STATUS_DISTRIBUTION,
        (gameStats) => {this.unpackStats(this.parseGameStats(gameStats))});
  }

  parseGameStats(stringifyStats) {
    return json.decode(stringifyStats);
  }

  void unpackStats(TransportStatsFormat stats) {
    stats.forEach((stat) {
      final values = new Map<String, bool>();
      values.addEntries(stat.values);
      final responses = new Map<String, num>();
      responses.addEntries(stat.responses);
      this.gameStats.add([values, responses, stat.question]);
    });
  }

  void getScore() {
    if (this._gameService.realGameService.username != 'host') {
      this._socketService.sendMessageWithAck(
            SocketEvent.GET_SCORE,
            {
              'roomId': this._gameService.realGameService.roomId,
              'username': this._gameService.realGameService.username,
            },
            (Score score) {
              this._gameService.realGameService.validated = true;
              this.updateScore(score.points);
              this.isBonus = score.isBonus;
            } as Function(dynamic p1),
          );
    }
  }

  void updateScore(int score) {
    final oldScore = this.playerScore;
    this.playerScore = score;
    if (this._gameService.question?.type == QuestionType.QRL) {
      this._gameService.lastQrlScore = (((playerScore - oldScore) /
              (_gameService.realGameService.question?.points ?? 0)) *
          100) as int?;
    }
  }
}

class Player {
  final String username;
  final int points;

  Player({required this.username, required this.points});
}
