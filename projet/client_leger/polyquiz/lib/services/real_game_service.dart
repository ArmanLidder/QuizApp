import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/enums/question_type.dart';
import 'package:polyquiz/models/initial_question_data.dart';
import 'package:polyquiz/models/next_question_data.dart';
import 'package:polyquiz/models/player.dart' as player;
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/services/translationService.dart';
// import 'package:polyquiz/services/game_interface_management_service.dart';

class RealGameService extends ChangeNotifier {
  static final RealGameService _instance = RealGameService._internal();
  Map get text => TranslationService.instance.text;
  Map get observerText => text['OBSERVER'];

  RealGameService._internal();

  factory RealGameService() {
    return _instance;
  }

  SocketService _socketService = SocketService();
  // GameInterfaceManagementService _gameInterfaceManagementService =
  //     GameInterfaceManagementService();

  String username = '';
  int roomId = 0;
  List<player.Player> players = [];
  Map<int, String?> answers = {};
  int questionNumber = 1;
  int timer = 0;
  QuizQuestion? question;
  late QuizQuestion oldQuestion;
  bool isLast = false;
  bool locked = false;
  bool validated = false;
  String qrlAnswer = '';
  int? qreAnswer = null;
  AudioPlayer audio = AudioPlayer();
  bool audioPaused = false;
  bool inTimeTransition = false;
  bool isNotified = false;
  bool isHostEvaluating = false;
  bool _isValidateButtonActive = true;
  bool isSentAnswer = false;
  bool qcmEnabled = false;
  bool isAION = false;
  bool observerMode = false;
  String obsQrlAnswer = '';
  Map<int, String?> obsAnswers = {};



  bool get isValidateActive => this._isValidateButtonActive;

  void set isValidateActive(bool newValue) {
    this._isValidateButtonActive = newValue;
    notifyListeners();
  }

  init([bool isObserver = false]) {
    if (isObserver) {
      this.observerMode = true;
      this.username = 'host';
    }
    this.configureBaseSocket();
    this._socketService.sendMessage(SocketEvent.GET_QUESTION, this.roomId);
    print('ROOM ID SENT: ${this.roomId}');
    this.audio.setSource(AssetSource('music.mp3'));
    this.audio.setVolume(0.1);
  }

  destroy() {
    this.reset();
    if (this._socketService.isSocketAlive())
      this._socketService.clearAllListeners();
  }

  void sendAnswer() {
    final isMultipleChoiceQuestion = this.question?.type == QuestionType.QCM;
    final isQREQuestion = this.question?.type == QuestionType.QRE;
    final answers = this.answers.values.toList();
    if (isQREQuestion) {
      this._socketService.sendMessage(SocketEvent.SUBMIT_ANSWER, {
        'roomId': this.roomId,
        'answers': this.qreAnswer,
        'timer': this.timer,
        'username': this.username,
      });
    } else {
      this._socketService.sendMessage(SocketEvent.SUBMIT_ANSWER, {
        'roomId': this.roomId,
        'answers': isMultipleChoiceQuestion ? answers : this.qrlAnswer.trim(),
        'timer': this.timer,
        'username': this.username,
      });
    }

    this.locked = true;
    this.answers.clear();
    this.qrlAnswer = '';
  }

  void configureBaseSocket() {
    this._socketService.onMessage(SocketEvent.GET_INITIAL_QUESTION, (data) {
      print(data);
      InitialQuestionData questionData = InitialQuestionData(
        question: QuizQuestion.fromJson(data['question']),
        username: data['username'] ?? 'host',
        index: data['index'],
        numberOfQuestions: data['numberOfQuestions'],
      );
      this.qcmEnabled = true;
      // this._gameInterfaceManagementService.changeQcmEnabled(true);
      this.question = questionData.question;
      if (!this.observerMode) this.username = questionData.username; // TODO: make sure this is needed
      this.oldQuestion = this.question!;
      if (!isNotified) {
        notifyListeners();
        isNotified = true;
      }

      if (questionData.numberOfQuestions == 1) {
        this.isLast = true;
      }
      this.isValidateActive = true;
    });

    this._socketService.onMessage(SocketEvent.GET_NEXT_QUESTION, (data) {
      if (observerMode) {
        this.obsQrlAnswer = observerText['QRL_PLAYER_INACTIVE'];
        this.obsAnswers.clear();
      }
        NextQuestionData nextQuestionData = NextQuestionData(
            question: QuizQuestion.fromJson(data['question']),
            index: data['index'],
            isLast: data['isLast']);
        this.qcmEnabled = true;
        // this._gameInterfaceManagementService.changeQcmEnabled(true);
        if (!isNotified) {
          notifyListeners();
          isNotified = true;
        }

        this.isHostEvaluating = false;
        this.isSentAnswer = false;
        this.question = nextQuestionData.question;
        this.oldQuestion = this.question!;
        this.questionNumber = nextQuestionData.index;
        this.isLast = nextQuestionData.isLast;
        this.validated = false;
        this.locked = false;
        this.isValidateActive = true;
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

  void sendQRESelection(int selectedAnswer) {
    if (!_socketService.isSocketAlive()) return;
    this._socketService.sendMessage(SocketEvent.UPDATE_QRE_SELECTION, {
      'roomId': this.roomId,
      'selectedAnswer': selectedAnswer,
    });
  }

  void notifyOnChanged() {
    notifyListeners();
  }

  void reset() {
    this.username = '';
    this.observerMode = false;
    this.roomId = 0;
    this.timer = 0;
    this.question = null;
    this.locked = false;
    this.validated = false;
    this.isLast = false;
    this.isHostEvaluating = false;
    this.isSentAnswer = false;
    this.players = [];
    this.answers.clear();
    this.qreAnswer = null;
    this.qrlAnswer = '';
    this.questionNumber = 1;
    this.audioPaused = false;
    this.inTimeTransition = false;
    this.isNotified = false;
    this.isAION = false;
    this._socketService.clearAllListeners();
    this.audio.stop();
  }
}
