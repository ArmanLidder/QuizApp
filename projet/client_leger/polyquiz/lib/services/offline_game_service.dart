import 'package:flutter/material.dart';
import 'package:polyquiz/classes/timer.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/time_service.dart';

class OfflineGameService extends ChangeNotifier {
  static final OfflineGameService _instance = OfflineGameService._internal();

  OfflineGameService._internal();

  factory OfflineGameService() {
    return _instance;
  }

  bool validated = false;
  bool gameOver = false;
  Map<int, String?> answers = {};
  bool locked = false;
  String quizId = '';
  bool isBonus = false;
  late ClientTimer timer;
  int playerScore = 0;
  QuizQuestion? question;
  late QuizQuestion oldQuestion;
  int currQuestionIndex = 0;
  String qrlAnswer = '';
  List<int> timeouts = [0, 0];
  late Quiz quiz;

  final TimeService timeService = TimeService();
  final QuizService quizService = QuizService();

  void init() {
    print(this.quiz.questions);
    this.question = quiz.questions[currQuestionIndex];
    timeService.deleteAllTimers();
  }

  bool next() {
    if (currQuestionIndex == quiz.questions.length - 1) {
      oldQuestion = question!;
      return false;
    }
    currQuestionIndex++;
    oldQuestion = question!;
    question = quiz.questions[currQuestionIndex];
    notifyListeners();
    return true;
  }

  void sendAnswer() {
    validated = true;
    locked = true;
    updateScore(answers);
  }

  void updateScore(Map<int, String?> answers) {
    int questionPoints = this.quiz.questions[this.currQuestionIndex].points;
    if (this.question!.type == QuestionType.QCM) {
      List<QuizChoice>? choices =
          this.quiz.questions[currQuestionIndex].choices;
      List<QuizChoice> correctChoices = this.extractCorrectChoices(choices);

      if (this.answers.length != correctChoices.length) {
        this.isBonus = false;
        return;
      }

      for (var entry in answers.entries) {
        int key = entry.key;
        String? value = entry.value;

        if (choices != null || choices![key].isCorrect == null) {
          if (key >= choices.length ||
              choices[key].text != value ||
              !choices[key].isCorrect!) {
            isBonus = false;
            return;
          }
        }

        this.isBonus = true;
        this.playerScore += (questionPoints * 1.2).toInt();
      }
    } else {
      this.isBonus = false;
      this.playerScore += questionPoints;
    }
  }

  void reset() {
    timeService.deleteAllTimers();
    playerScore = 0;
    currQuestionIndex = 0;
    isBonus = false;
    gameOver = false;
    locked = false;
    validated = false;
    qrlAnswer = '';
  }

  void hideFeedback() {
    validated = false;
    locked = false;
    isBonus = false;
    answers.clear();
  }

  void showFinalFeedBack() {
    validated = true;
    locked = true;
    gameOver = true;
  }

  List<QuizChoice> extractCorrectChoices(List<QuizChoice>? choices) {
    if (choices == null) return [];
    return choices.where((choice) => choice.isCorrect == true).toList();
  }
}
