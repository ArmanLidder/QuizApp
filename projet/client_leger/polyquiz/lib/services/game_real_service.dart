import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/initial_question_data.dart';
import 'package:polyquiz/models/next_question_data.dart';
import 'package:polyquiz/models/player.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/socket_service.dart';

class GameRealService {
  static final GameRealService _instance = GameRealService._internal();

  GameRealService._internal();

  factory GameRealService() {
    return _instance;
  }

  SocketService _socketService = SocketService();

  String username = '';
  int roomId = 0;
  List<Player> players = [];
  Map<int, String?> answers = {};
  int questionNumber = 1;
  int timer = 0;
  QuizQuestion? question;
  bool isLast = false;
  bool locked = false;
  bool validated = false;
  String qrlAnswer = '';
  //late Audio audio;
  bool audioPaused = false;
  bool inTimeTransition = false;

  init() {
    this.configureBaseSocket();
    this._socketService.sendMessage(SocketEvent.GET_QUESTION, this.roomId);
  }

  destroy() {
    this.reset();
    if (this._socketService.isSocketAlive())
      this._socketService.clearAllListeners();
  }

  void sendAnswer() {
    final isMultipleChoiceQuestion = question?.type == QuestionType.QCM;
    final answers = this.answers.values.toList();

    this._socketService.sendMessage(SocketEvent.SUBMIT_ANSWER, {
      'roomId': this.roomId,
      'answers': isMultipleChoiceQuestion ? answers : this.qrlAnswer.trim(),
      'timer': this.timer,
      'username': this.username,
    });

    this.locked = true;
    this.answers.clear();
    this.qrlAnswer = '';
  }

  void configureBaseSocket() {
    this._socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION, (data) {
      InitialQuestionData questionData = InitialQuestionData(
        question: data['question'],
        username: data['username'],
        index: data['index'],
        numberOfQuestions: data['numberOfQuestions'],
      );

      this.question = questionData.question;

      if (questionData.numberOfQuestions == 1) {
        this.isLast = true;
      }
    });

    this._socketService.onMessage(SocketEvent.GET_NEXT_QUESTION, (data) {
      NextQuestionData nextQuestionData = NextQuestionData(
          question: data['question'],
          index: data['index'],
          isLast: data['isLast']);

      this.question = nextQuestionData.question;
      this.questionNumber = nextQuestionData.index;
      this.isLast = nextQuestionData.isLast;
      this.validated = false;
      this.locked = false;
    });
  }

  void sendSelection(int index, bool isSelected) {
    if (_socketService.isSocketAlive()) {
      _socketService.sendMessage(SocketEvent.UPDATE_SELECTION, {
        'roomId': this.roomId,
        'isSelected': isSelected,
        'index': index,
      });
    }
  }

  void reset() {
    this.username = '';
    this.roomId = 0;
    this.timer = 0;
    this.question = null;
    this.locked = false;
    this.validated = false;
    this.isLast = false;
    this.players = [];
    this.answers.clear();
    this.qrlAnswer = '';
    this.questionNumber = 1;
    this.audioPaused = false;
    this.inTimeTransition = false;
  }
}
