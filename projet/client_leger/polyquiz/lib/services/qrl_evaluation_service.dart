import 'dart:convert';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/typedefs.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class QrlEvaluationService {
  static final QrlEvaluationService _instance =
      QrlEvaluationService._internal();

  QrlEvaluationService._internal();

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

  void initialize(Map<String, QrlAnswer> qrlAnswers) {
    this.indexPlayer = -1;
    this.isCorrectionFinished = false;
    this.initializePlayerAnswers(qrlAnswers);
    this.nextAnswer();
  }

  void getCorrection(int point) {
    this.points[this.indexPlayer] = point;
  }

  void nextAnswer() {
    this.indexPlayer++;
    if (this.indexPlayer <= this.usernames.length) {
      this.currentAnswer = this.answers[this.indexPlayer];
      this.currentUsername = this.usernames[this.indexPlayer];
    }
  }

  void reset() {
    this.clearAll();
    this.isCorrectionFinished = false;
    this.isValid = true;
    this.currentAnswer = '';
    this.currentUsername = '';
  }

  void clearAll() {
    usernames.clear();
    answers.clear();
    points.clear();
    correctedQrlAnswers.clear();
    questionStats.clear();
    questionStats.addAll({
      '0': 0,
      '50': 0,
      '100': 0,
    });

    indexPlayer = -1;
  }

  void submitPoint(List<QuestionStatistics> gameStats) {
    this.isValid = scores.contains(int.tryParse(inputPoint.toString()));

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
          (this.questionStats[this.points[i]]! + 1);
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

  void initializePlayerAnswers(Map<String, QrlAnswer> qrlAnswers) {
    var sortedEntries = qrlAnswers.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedEntries) {
      var key = entry.key;
      var value = entry.value;

      usernames.add(key);
      answers.add(value.answers);
    }
  }
}
