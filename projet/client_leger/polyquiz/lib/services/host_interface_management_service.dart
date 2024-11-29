import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/constants/timer_message.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/current_game_interface.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/interactive_list_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'dart:convert';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/openai_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/qrl_evaluation_service.dart';

class HostInterfaceManagementService extends ChangeNotifier {
  static final HostInterfaceManagementService _instance =
      HostInterfaceManagementService._internal();

  HostInterfaceManagementService._internal();

  factory HostInterfaceManagementService() {
    return _instance;
  }

  String? _timerText = null;
  String get timerText {
    if (_timerText == null) _timerText = timerTransText['TIME_LEFT'];
    return _timerText!;
  }
  void set timerText(String value) => _timerText = value;
  Map get transText => TranslationService.instance.text['GAME_INTERFACE'];
  Map get timerTransText => transText['TIMER_TEXT'];
  Map get qreValueText => transText['QRE_HISTOGRAM_X_VAL'];
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
  bool isResultPage = false;
  Function(Map<String, ResponseData>)? _qrlCallback;
  Map<String, List<dynamic>> correctedQrlByOpenAi = {};

  GameService gameService = GameService();
  SocketService _socketService = SocketService();
  InteractiveListService _interactiveListService = InteractiveListService();
  InteractiveListService get interactiveListService => _interactiveListService;
  OpenaiService openIA = OpenaiService();


  void set qrlCallback(Function(Map<String, ResponseData>) callback) {
    this._qrlCallback = callback;
  }

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
      // Create deep copies of the maps
      final valuesCopy = Map<String, bool>.from(this.histogramDataValue);
      final responsesCopy = Map<String, int>.from(this.histogramDataChangingResponses);
      
      QuestionStatistics savedStats = QuestionStatistics(
          valuesCopy,
          responsesCopy,
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
    if (this.gameService.isObserverMode) return;
    this._socketService.sendMessage(SocketEvent.START_TRANSITION, this.roomId);
  }

  void handleLastQuestion() {
    this.sendGameStats();
    this._socketService.sendMessage(SocketEvent.SHOW_RESULT, this.roomId);
  }

  configureBaseSocketFeatures(BuildContext context) {
    if (!this.gameService.isObserverMode) {
      this.reset(context);
      this.handleRequestHostGameStatus();
    }
    this.handleTimeTransition();
    this.handleEndQuestion();
    this.handleFinalTimeTransition();
    this.handleRefreshChoicesStats();
    this.handleQreRefresh();
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

  void handleRequestHostGameStatus() {
    this._socketService.onMessage(SocketEvent.REQUEST_HOST_GAME_STATUS, (_) {
      List<int> histogramDataChangingResponses = [];

      switch (this.gameService.realGameService.question?.type) {
        case QuestionType.QRE:
          histogramDataChangingResponses = [
            this.histogramDataChangingResponses[qreValueText['WITHIN_MARGIN']] ?? 0,
            this.histogramDataChangingResponses[qreValueText['EXACT_ANSWER']] ?? 0,
            this.histogramDataChangingResponses[qreValueText['INCORRECT_ANSWER']] ?? 0
          ];
          break;
        default:
          histogramDataChangingResponses = [
            this.histogramDataChangingResponses[transText['HISTOGRAM']['ACTIVE']] ?? 0,
            this.histogramDataChangingResponses[transText['HISTOGRAM']['INACTIVE']] ?? 0,
          ];
          break;
      }

      final gameStatus = {
      "roomId": this.roomId,
      "timerText": this.timerText,
      "currentTime": this.gameService.realGameService.timer,
      "isGameOver": this.isGameOver,
      "leftPlayers": this.leftPlayers,
      "players": this.interactiveListService.players,
      "histogramDataChangingResponses": this.gameService.realGameService.question?.type == QuestionType.QCM ? [1000] : histogramDataChangingResponses,
      "isHostEvaluating": this.isHostEvaluating,
      "gameStats": this.stringifyStats(),
      "isPaused": this.isPaused,
      "isPanicMode": this.isPanicMode,
      "isValidated": this.gameService.realGameService.validated
      };
      this._socketService.sendMessage(SocketEvent.SENDING_HOST_GAME_STATUS, gameStatus);
    });
  }

  void handleTimeTransition() {
    this._socketService.onMessage(SocketEvent.TIME_TRANSITION, (timeValue) {
      if (this.gameService.isObserverMode) {
        this.obsHandleTimeTransition(timeValue);
        notifyListeners();
        return;
      }
      this.timerText = timerTransText['NEXT'];
      this.gameService.realGameService.timer = timeValue;
      notifyListeners();
      if (this.gameService.realGameService.timer == 0) {
        this.gameService.realGameService.inTimeTransition = false;
        this.resetInterface();
        this._socketService.sendMessage(
            SocketEvent.NEXT_QUESTION, this.gameService.realGameService.roomId);
        this.timerText = timerTransText['TIME_LEFT'];
      }
    });
  }

  void obsHandleTimeTransition(int timeValue) {
    this.timerText = timerTransText['NEXT'];
    if (this.gameService.isObservingHost) this.gameService.realGameService.timer = timeValue;
    if (this.gameService.timer == 0) {
      if (this.gameService.isObservingHost) {
        this.gameService.realGameService.inTimeTransition = false;
        this.resetInterface();
      }
      this.timerText = timerTransText['TIME_LEFT'];
    }
  }

  void handleEndQuestion() {
    this._socketService.onMessage(SocketEvent.END_QUESTION, (_) {
      if (this.gameService.isObserverMode) {
        this.obsHandleEndQuestion();
        return;
      }
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.gameService.realGameService.inTimeTransition = true;
      this.resetInterface();

      QuestionType? type = this.gameService.question?.type ?? null;
      switch (type) {
        case QuestionType.QRL:
          this.sendQrlAnswer();
          this.isHostEvaluating = true;
          // this.NextQuestionBtnDisabled = false;
          notifyListeners();
          break;
        case QuestionType.QRE:
        case QuestionType.QCM:
        default:
          this._interactiveListService.getPlayersList(roomId,
              leftPlayers: leftPlayers, resetPlayerStatus: false);
          this.NextQuestionBtnDisabled = false;
          break;
      }
      //
      // if (this.gameService.question?.type == QuestionType.QCM) {
      //   this._interactiveListService.getPlayersList(roomId, leftPlayers: leftPlayers, resetPlayerStatus: false);
      // } else {
      //   this.sendQrlAnswer();
      //   this.isHostEvaluating = true;
      //   notifyListeners();
      // }
    });
  }

  void obsHandleEndQuestion() {
    if (this.gameService.isObservingHost) {
      this.gameService.audio.pause();
      this.gameService.audio.seek(Duration.zero);
      this.gameService.realGameService.audioPaused = false;
      this.gameService.realGameService.inTimeTransition = true;
      this.resetInterface();
    }
    switch (this.gameService.question?.type) {
      case QuestionType.QRE:
      case QuestionType.QCM:
        if (this.gameService.isObservingHost)
          this.interactiveListService.getPlayersList(this.roomId, leftPlayers: this.leftPlayers, resetPlayerStatus: false);
        break;
      case QuestionType.QRL:
      default:
        this.isHostEvaluating = true;
    }
  }

  void handleFinalTimeTransition() {
    this._socketService.onMessage(SocketEvent.FINAL_TIME_TRANSITION,
        (timeValue) {
      if (this.gameService.isObserverMode) {
        this.obsHandleEndQuestion();
        return;
      }
      this.timerText = timerTransText['RESULT_AVAILABLE_IN'];
      this.gameService.realGameService.timer = timeValue;

      if (this.gameService.timer == 0) {
        this.isResultPage = true;
        this.isGameOver = true;
        this._interactiveListService.isFinal = true;
        this.gameService.audio.pause();
        this._interactiveListService.getPlayersList(this.roomId, leftPlayers: leftPlayers);
        this._socketService.sendMessage(SocketEvent.SAVE_FINAL_GAME_STATS, this.gameService.realGameService.roomId);
      }
      notifyListeners();
    });
  }

  void obsHandleFinalTimeTransition(int timeValue) {
    this.timerText = timerTransText['RESULT_AVAILABLE_IN'];
    if (this.gameService.isObservingHost) this.gameService.realGameService.timer = timeValue;
    if (this.gameService.timer == 0) {
      this.isGameOver = true;
      this.interactiveListService.isFinal = true;
      this.gameService.audio.pause();
      this.interactiveListService.getPlayersList(this.roomId, leftPlayers: this.leftPlayers);
      this.isResultPage = true;
      notifyListeners();
    }
  }

  void handleRefreshChoicesStats() {
    this._socketService.onMessage(SocketEvent.REFRESH_CHOICES_STATS,
        (choicesStatsValue) {
      this.histogramDataChangingResponses =
          createChoicesStatsMap(List<num>.from(choicesStatsValue));
      notifyListeners();
    });
  }

  void handleQreRefresh() {
    this._socketService.onMessage(SocketEvent.REFRESH_QRE_STATS, (qreStatsValue) {
      final values = (qreStatsValue as List).map((element) => element as int).toList();
      this.histogramDataChangingResponses = {
            qreValueText['WITHIN_MARGIN']: values[0],
            qreValueText['EXACT_ANSWER']: values[1],
            qreValueText['INCORRECT_ANSWER']: values[2]
          };
          notifyListeners();
        });
  }

  void handleGetInitialQuestion() {
    this._socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION,
        (data) async {
      // if (isAlreadyCalled)
      //   return;
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
        this._interactiveListService.getPlayersList(roomId,
            leftPlayers: leftPlayers, resetPlayerStatus: false);
      }
    });
  }

  void handleEndQuestionAfterRemoval() {
    this._socketService.onMessage(SocketEvent.END_QUESTION_AFTER_REMOVAL, (_) {
      if (!this.gameService.isObserverMode || this.gameService.isObservingHost) resetInterface();
    });
  }

  void handleHostPanicMode() {
    this._socketService.onMessage(SocketEvent.PANIC_MODE, (_) {
      if (!this.gameService.isObserverMode || this.gameService.isObservingHost) {
        if (this.gameService.timer > 0 &&
            !this.gameService.realGameService.audioPaused) {
          this.gameService.audio.play(AssetSource('music.mp3'));
        }
      }
      this.isPanicMode = true;
    });
  }

  void handleHostTimerPause() {
    this._socketService.onMessage(SocketEvent.PAUSE_TIMER, (_) {
      if (!this.gameService.isObserverMode || !this.gameService.isObservingHost) {
        if (this.gameService.realGameService.audioPaused && this.isPanicMode) {
          this.gameService.audio.play(AssetSource('music.mp3'));
        } else if (!this.gameService.realGameService.audioPaused &&
            this.isPanicMode) {
          this.gameService.audio.pause();
        }
        this.gameService.realGameService.audioPaused =
        !this.gameService.realGameService.audioPaused;
      }
    });
  }

  void handleEvaluationOver() {
    this._socketService.onMessage(SocketEvent.EVALUATION_OVER, (_) {
      this.NextQuestionBtnDisabled = false;
      _interactiveListService.getPlayersList(roomId,
          leftPlayers: leftPlayers, resetPlayerStatus: false);
      notifyListeners();
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
    this.isHostEvaluating = false;
    switch (question.type) {
      case QuestionType.QCM:
        if (question.choices == null) {
          notifyListeners();
          return;
        }
        for (QuizChoice choice in question.choices!) {
          this
              .histogramDataValue
              .addEntries(<String, bool>{choice.text: choice.isCorrect!}.entries);
        }
        break;
      case QuestionType.QRL:
        this.histogramDataChangingResponses = {
            'Actif': 0,
            'Inactif': numberOfPlayers,
          };
          this.histogramDataValue = {
            'Actif': true,
            'Inactif': false,
        };
        break;
      case QuestionType.QRE:
        this.histogramDataValue = {
          qreValueText['WITHIN_MARGIN']: true,
          qreValueText['EXACT_ANSWER']: true,
          qreValueText['INCORRECT_ANSWER']: false,
        };
        break;
      default:
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
      if (_qrlCallback != null) _qrlCallback!(this.responsesQRL);
      if (gameService.realGameService.isAION) {
        this.openIA.init();
        this.responsesQRL.forEach((key, value) {
          this.openIA.correctAnswer(value.answers, this.gameService.question?.text ?? "", TranslationService.instance.currentLanguageAbbr)
            .then((response) {
              final res = response['choices'][0]['message']['content'] ?? "No Answer";
              final score = this.extractScoreFromIAQRL(res);
              this.correctedQrlByOpenAi[key] = [score, res];
              notifyListeners();
            });
        });
      }
      notifyListeners();
    });
  }

  int extractScoreFromIAQRL(String qrlText) {
    final patternAa = RegExp(r'Aa');
    final patternBb = RegExp(r'Bb');
    final patternCc = RegExp(r'Cc');

    if (patternCc.hasMatch(qrlText)) {
      return 100;
    } else if (patternBb.hasMatch(qrlText)) {
      return 50;
    } else if (patternAa.hasMatch(qrlText)) {
      return 0;
    }
    return 0;
  }

  void sendGameStats() {
    final gameStats = this.stringifyStats();
    this._socketService.sendMessage(SocketEvent.GAME_STATUS_DISTRIBUTION, {
      'roomId': this.gameService.realGameService.roomId,
      'stats': gameStats,
    });
  }

  String stringifyStats() {
    final stats = this.prepareStatsTransport();
    return jsonEncode(stats.map((stat) => stat.toJson()).toList());
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
    this.timerText = timerTransText['TIME_LEFT'];
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
    this.isResultPage = false;
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
