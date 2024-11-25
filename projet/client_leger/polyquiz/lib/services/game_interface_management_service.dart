import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/current_game_interface.dart';
import 'package:polyquiz/models/score.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/models/quiz.dart';

class GameInterfaceManagementService extends ChangeNotifier {
  static final GameInterfaceManagementService _instance =
      GameInterfaceManagementService._internal();

  GameInterfaceManagementService._internal();
  Map get gameText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get timerTransText => gameText['TIMER_TEXT'];
  Map get observerText => TranslationService.instance.text['OBSERVER_INTERFACE'];


  factory GameInterfaceManagementService() {
    return _instance;
  }

  bool isBonus = false;
  bool isGameOver = false;
  bool _qcmEnabled = true;
  int playerScore = 0;
  List<PlayerScore> players = [];
  bool inPanicMode = false;
  List<QuestionStatistics> gameStats = []; // Type a revoir
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
    if (this.gameService.isObserverMode) return;
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
    if (!this.gameService.isObservingHost) {
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.gameService.realGameService.locked = false;
      this.gameService.realGameService.validated = false;
    }
    this.inPanicMode = false;
    this.isBonus = false;
    this.isDefaultTimerMessage = true;
  }

  void handleEndQuestion() {
    this._socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      if (this.gameService.isObserverMode) {
        this.obsHandleEndQuestion();
        notifyListeners();
        return;
      }
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.inPanicMode = false;
      switch (this.gameService.question?.type) {
        case QuestionType.QRL:
          this.gameService.realGameService.isHostEvaluating = true;
          this.gameService.qrlAnswer = '';
          this.gameService.realGameService.validated = true;
          break;
        default:
          this.getScore();
          this.changeQcmEnabled(false);
          this.gameService.realGameService.qcmEnabled = false;
          break;
      }
      this.gameService.realGameService.isNotified = false;
      this.gameService.realGameService.isValidateActive = false;
      notifyListeners();
    });
  }

  void obsHandleEndQuestion() {
    if (!this.gameService.isObservingHost) {
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = true;
    }
    this.inPanicMode = false;
    switch (this.gameService.question?.type) {
      case QuestionType.QCM:
      case QuestionType.QRE:
        this.getScore();
        this.gameService.realGameService.validated = true;
        break;
      case QuestionType.QRL:
      default:
        this.gameService.realGameService.isHostEvaluating = true;
        this.gameService.qrlAnswer = observerText['INACTIVE_PLAYER'];
        if (!this.gameService.isObservingHost) this.gameService.realGameService.validated = true;
    }
    notifyListeners();
  }

  void handleEvaluationOver() {
    this._socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      this.getScore();
      notifyListeners();
    });
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      if (!this.gameService.isObserverMode) {
        this.gameService.realGameService.timer = timeValue;
        if (this.gameService.timer == 0) {
          this.resetData();
        }
      } else if (!this.gameService.isObservingHost) {
        this.gameService.realGameService.timer = timeValue;
        if (this.gameService.timer == 0) {
          this.resetData();
        }
      }
      notifyListeners();
    });
  }

  void handleFinalTimeTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION,
        (timeValue) {
          //todo code pour afficher la transition aux resultats finaux
          if (!this.gameService.isObserverMode) {
            this.gameService.realGameService.timer = timeValue;
            this.isDefaultTimerMessage = false;
            if (this.gameService.timer == 0) {
              this.isGameOver = true;
              this._interactiveListService.isFinal = true;
              this.isResultPage = true;
            }
          } else {
            this.isDefaultTimerMessage = false;
            if (!this.gameService.isObservingHost) this.gameService.realGameService.timer = timeValue;
            if (this.gameService.timer == 0) {
              this.isGameOver = true;
              this._interactiveListService.isFinal = true;
            }
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
      if (!this.gameService.isObserverMode) {
        if (this.gameService.timer > 0 &&
            !this.gameService.realGameService.audioPaused) {
          this.gameService.audio.play(AssetSource('music.mp3'));
        }
      } else if (!this.gameService.isObservingHost) {
        if (this.gameService.timer > 0 &&
            !this.gameService.realGameService.audioPaused) {
          this.gameService.audio.play(AssetSource('music.mp3'));
        }
      }
      this.inPanicMode = true;
      notifyListeners();
    });
  }

  void handlePauseTimer() {
    this._socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      final audio = AssetSource('music.mp3');
      if (!this.gameService.isObserverMode) {
        if (this.gameService.realGameService.audioPaused && this.inPanicMode) {
          this.gameService.audio.play(audio);
        } else if (!this.gameService.realGameService.audioPaused &&
            this.inPanicMode) {
          this.gameService.audio.pause();
        }
        this.gameService.realGameService.audioPaused =
        !this.gameService.realGameService.audioPaused;
        notifyListeners();
      } else if (!this.gameService.isObservingHost) {
        if (this.gameService.realGameService.audioPaused && this.inPanicMode) this.gameService.audio.play(audio);
        else if (!this.gameService.realGameService.audioPaused && this.inPanicMode) this.gameService.audio.pause();
        this.gameService.realGameService.audioPaused = !this.gameService.realGameService.audioPaused;
      }
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

  

  List<QuestionStatistics> parseGameStats(dynamic stringifyStats) {
    final List<dynamic> jsonList = jsonDecode(stringifyStats);
    return jsonList.map((questionData) {
      final responseValues = Map<String, bool>.fromEntries(
        (questionData[0] as List).map((e) => MapEntry(e[0] as String, e[1] as bool))
      );
      final responseNumbers = Map<String, num>.fromEntries(
        (questionData[1] as List).map((e) => MapEntry(e[0] as String, e[1] as num))
      );
      final question = questionData[2] as Map<String, dynamic>;
      return QuestionStatistics(responseValues, responseNumbers, QuizQuestion.fromJson(question));
    }).toList();
  }
  
  void unpackStats(List<QuestionStatistics> stats) {
    stats.forEach((stat) {
      final values = new Map<String, bool>();
      values.addEntries(stat.responsesValues.entries);
      final responses = new Map<String, num>();
      responses.addEntries(stat.responsesNumber.entries);
      this.gameStats.add(QuestionStatistics(values, responses, stat.question));
    });
  }

  void getScore() {
    if (this.gameService.realGameService.username != 'host') {
      final username = this.gameService.isObserverMode ? this.gameService.observedUid : this.gameService.realGameService.username;
      this._socketService.sendMessageWithAck(
        SocketEvent.GET_SCORE,
        {
          'roomId': this.gameService.realGameService.roomId,
          'username': username,
        },
        (dynamic response) {
          final score = Score.fromJson(response);
          if (!this.gameService.isObservingHost) this.gameService.realGameService.validated = true;
          this.updateScore(score.points);
          this.isBonus = score.isBonus;
        },
      );
    }
  }

  void updateScore(int score) {
    final oldScore = this.playerScore;
    this.playerScore = score;
    if (this.gameService.question?.type == QuestionType.QRL && !this.gameService.isObserverMode) {
      this.gameService.lastQrlScore = (((playerScore - oldScore) /
                  (gameService.realGameService.question?.points ?? 0)) *
              100)
          .toInt();

      print("I am Here 444444");
      print(this.gameService.lastQrlScore);
      notifyListeners();
    }
  }

  void changeQcmEnabled(bool value) {
    this._qcmEnabled = value;
    notifyListeners();
  }

  bool getQcmEnabled() {
    if(this.gameService.realGameService.qcmEnabled){
      return true;
    }
    return this._qcmEnabled;
  }
}