import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/models/timer.dart';
import 'package:polyquiz/models/player.dart';
import 'package:polyquiz/constants/constants.dart';
import 'package:polyquiz/constants/question_type.dart';
import 'package:polyquiz/services/time_service.dart';

class GameTestService {
  bool validated = false;
  bool gameOver = false;
  Map<int, String?> answers = {};
  bool locked = false;
  String quizId = '';
  bool isBonus = false;
  Timer? timer;
  int playerScore = 0;
  QuizQuestion? question;
  int currQuestionIndex = 0;
  String qrlAnswer = '';
  List<Future<void>> timeouts = [Future.value(), Future.value()];
  late Quiz quiz;

  final TimeService timeService;
  final QuizService quizService;

  GameTestService({
    required this.timeService,
    required this.quizService,
  });

  void init() {
    getQuiz(quizId).then((quiz) {
      this.quiz = quiz;
      this.question = quiz.questions[currQuestionIndex];
      timeService.deleteAllTimers();
      startTimer(question?.type == QuestionType.QCM ? quiz.duration : QRL_DURATION);
      handleQuestionTimerEnd();
    });
  }

  Future<Quiz> getQuiz(String quizId) {
    return quizService.fetchQuizById(quizId);
  }

  bool next() {
    if (timeService.getTimer(0) != null) {
      if (currQuestionIndex == quiz.questions.length - 1) return false;
      currQuestionIndex++;
      question = quiz.questions[currQuestionIndex];
    }
    return true;
  }

  void sendAnswer() {
    validated = true;
    locked = true;
    clearTimeout(timeouts[0]);
    updateScore(answers);
    startTimer(TESTING_TRANSITION_TIMER);
    handleTransitionTimer();
  }

  void updateScore(Map<int, String?> answers) {
    final questionPoints = quiz.questions[currQuestionIndex].points;
    if (question?.type == QuestionType.QCM) {
      final choices = quiz.questions[currQuestionIndex].choices as List<QuizChoice>;
      final correctChoices = extractCorrectChoices(choices);
      if (answers.length != correctChoices?.length) {
        isBonus = false;
        return;
      }
      for (var entry in answers.entries) {
        final key = entry.key;
        final value = entry.value;
        if (choices[key].text != value) {
          isBonus = false;
          return;
        }
      }
      isBonus = true;
      playerScore += (questionPoints * BONUS_MULTIPLIER).toInt();
    } else {
      isBonus = false;
      playerScore += questionPoints;
    }
  }

  void startTimer(int duration) {
    if (timeService.timersArray.isNotEmpty) {
      timeService.deleteAllTimers();
    }
    timer = timeService.createTimer(duration) as Timer?;
    timeService.startTimer(0);
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
    clearTimeout(timeouts[0]);
    clearTimeout(timeouts[1]);
  }

  void handleQuestionTimerEnd() {
    const tick = Duration(seconds: 1);
    timeouts[0] = Future.delayed(Duration(seconds: quiz.duration), () {
      sendAnswer();
    });
  }

  void handleTransitionTimer() {
    const tick = Duration(seconds: 1);
    timeouts[1] = Future.delayed(Duration(seconds: TESTING_TRANSITION_TIMER), () {
      hideFeedback();
      if (next()) {
        startTimer(quiz.duration);
        handleQuestionTimerEnd();
      } else {
        showFinalFeedBack();
      }
    });
  }

  void hideFeedback() {
    validated = false;
    locked = false;
    isBonus = false;
    clearTimeout(timeouts[0]);
    clearTimeout(timeouts[1]);
    answers.clear();
  }

  void showFinalFeedBack() {
    validated = true;
    locked = true;
    gameOver = true;
  }

  List<QuizChoice>? extractCorrectChoices(List<QuizChoice>? choices) {
    return choices?.where((choice) => choice.isCorrect == true).toList();
  }

  void clearTimeout(Future<void> timeout) {
    // Implement clearTimeout logic if needed
  }
}