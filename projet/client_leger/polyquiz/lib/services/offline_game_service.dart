import 'package:polyquiz/classes/timer.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/quiz_service.dart';
import 'package:polyquiz/services/time_service.dart';

class OfflineGameService {
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
  int currQuestionIndex = 0;
  String qrlAnswer = '';
  List<int> timeouts = [0, 0];
  late Quiz quiz;

  final TimeService timeService = TimeService();
  final QuizService quizService = QuizService();

  void init() {
    getQuiz(quizId).then((quiz) {
      this.quiz = quiz;
      this.question = quiz.questions[currQuestionIndex];
      timeService.deleteAllTimers();
      //startTimer(question?.type == QuestionType.QCM ? quiz.duration : 60);
      //handleQuestionTimerEnd();
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
    //clearTimeout(timeouts[0]);
    updateScore(answers);
    //startTimer(3);
    //handleTransitionTimer();
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
          if (key >= choices!.length ||
              choices[key].text != value ||
              !choices[key].isCorrect!) {
            isBonus = false;
            return;
          }
        }

        this.isBonus = true;
        this.playerScore += (questionPoints * 1.2) as int;
      }
    } else {
      this.isBonus = false;
      this.playerScore += questionPoints;
    }
  }

  void startTimer(int duration) {
    if (timeService.timersArray[0] != null) {
      timeService.deleteAllTimers();
    }
    timer = timeService.createTimer(duration);
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
    //clearTimeout(timeouts[0]);
    //clearTimeout(timeouts[1]);
  }

  // void handleQuestionTimerEnd() {
  //   const tick = 1000;
  //   timeouts[0] = window.setTimeout(() {
  //     sendAnswer();
  //   }, quiz.duration * tick);
  // }

  // void handleTransitionTimer() {
  //   const tick = 1000;
  //   timeouts[1] = window.setTimeout(() {
  //     hideFeedback();
  //     if (next()) {
  //       startTimer(quiz.duration);
  //       handleQuestionTimerEnd();
  //     } else {
  //       showFinalFeedBack();
  //     }
  //   }, TESTING_TRANSITION_TIMER * tick);
  // }

  void hideFeedback() {
    validated = false;
    locked = false;
    isBonus = false;
    //clearTimeout(timeouts[0]);
    //clearTimeout(timeouts[1]);
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
