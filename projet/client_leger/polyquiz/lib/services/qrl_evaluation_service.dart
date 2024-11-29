import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/host_interface_management_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/openai_service.dart';


class QrlEvaluationService extends ChangeNotifier {
  static final QrlEvaluationService _instance =
      QrlEvaluationService._internal();

  QrlEvaluationService._internal();
  HostInterfaceManagementService hostInterfaceManagementService = HostInterfaceManagementService();

  factory QrlEvaluationService() {
    return _instance;
  }

  List<String> usernames = [];
  List<int> scores = [0, 50, 100];
  String currentAnswer = '';
  String currentUsername = '';
  int inputPoint = 0;
  bool isCorrectionFinished = false;
  bool isValid = true;
  List<int> points = [];
  // Map<String, List<dynamic>> correctedQrlByOpenAi = {};

  final Map<String, int> correctedQrlAnswers = {};
  List<String> answers = [];
  int indexPlayer = -1;

  final Map<String, int> questionStats = {
    '0': 0,
    '50': 0,
    '100': 0,
  };

  SocketService _socketService = SocketService();
  GameService _gameService = GameService();
  GameConfigService gameConfigs = GameConfigService();
  OpenaiService openai = OpenaiService();


  void initialize(Map<String, ResponseData> qrlAnswers) {
    this.indexPlayer = -1;
    this.isCorrectionFinished = false;
    hostInterfaceManagementService.qrlCallback = this.initializePlayerAnswers; 
    this.initializePlayerAnswers(qrlAnswers);
    if (this.hostInterfaceManagementService.gameService.realGameService.isAION) {
      this.openai.init();
    }
  }

  void getCorrection(int point) {
    this.points.add(point);
  }

  void nextAnswer() {
    this.indexPlayer++;
    if (this.indexPlayer < this.usernames.length) {
      this.currentAnswer = this.answers[this.indexPlayer];
      this.currentUsername = this.usernames[this.indexPlayer];
    }
    notifyListeners();
  }

  Map<String, List<dynamic>> get correctedQrlByOpenAi {
    return this.hostInterfaceManagementService.correctedQrlByOpenAi;
  }

  void reset() {
    this.clearAll();
    this.isCorrectionFinished = false;
    this.isValid = true;
    this.currentAnswer = '';
    this.currentUsername = '';
    this.inputPoint = 0;
    notifyListeners();
  }

  void clearAll() {
    usernames.clear();
    answers.clear();
    points.clear();
    correctedQrlAnswers.clear();
    questionStats.clear();
    this.hostInterfaceManagementService.correctedQrlByOpenAi.clear();
    questionStats.addAll({
      '0': 0,
      '50': 0,
      '100': 0,
    });

    indexPlayer = -1;
  }

  void submitPoint(List<QuestionStatistics> gameStats) {
    this.isValid = scores.contains(inputPoint);
    if (indexPlayer < usernames.length) {
      if (isValid) {
        getCorrection(inputPoint);
        nextAnswer();
        inputPoint = 0;
      }

      if (indexPlayer >= usernames.length) {
        isCorrectionFinished = true;
        endCorrection(gameStats);
        sendPlayerEvaluations();
      }
    }
  }

  void endCorrection(List<QuestionStatistics> gameStats) {
    for (int i = 0; i < this.usernames.length; i++) {
      this.correctedQrlAnswers[this.usernames[i]] = this.points[i];
      this.questionStats[this.points[i].toString()] =
          int.parse(this.questionStats[this.points[i].toString()]!.toString()) +
              1;
    }

    final emptyMap = {
      '0': false,
      '50': false,
      '100': true,
    };

    final newQuestionMap = Map<String, int>.from(this.questionStats);

    gameStats.add(QuestionStatistics(
        emptyMap, newQuestionMap, this._gameService.realGameService.question));
  }

  void sendPlayerEvaluations() {
    final playerQrlCorrectionFormatted = jsonEncode(correctedQrlAnswers.entries
        .map((entry) => [entry.key, entry.value])
        .toList());

    _socketService.sendMessage(SocketEvent.PLAYER_QRL_CORRECTION, {
      'roomId': _gameService.realGameService.roomId,
      'playerCorrection': playerQrlCorrectionFormatted,
    });
  }

  void initializePlayerAnswers(Map<String, ResponseData> qrlAnswers) {
    usernames.clear();
    answers.clear();
    var sortedEntries = qrlAnswers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    var random = Random();
    sortedEntries.shuffle(random);

    for (var entry in sortedEntries) {
      var key = entry.key;
      var value = entry.value;

      usernames.add(key);
      answers.add(value.answers);
    }
    indexPlayer = -1;
    this.nextAnswer();
    notifyListeners();
  }
}
