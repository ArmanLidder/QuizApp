import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/offline_game_service.dart';
import 'package:polyquiz/services/real_game_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class GameService extends ChangeNotifier {
  static final GameService _instance = GameService._internal();

  GameService._internal();

  factory GameService() {
    return _instance;
  }

  bool isOfflineMode = false;
  bool isInputFocused = false;
  Map<int, String?> answers = {};
  String qrlAnswer = '';
  bool isActive = false;
  bool hasInteracted = false;
  int? lastQrlScore;
  int qreAnswer = 0;
  bool gotNotified = false;
  bool isQuitBtn = false;

  bool isObserverMode = false;
  bool isObservingHost = true;
  String observedUid = '';

  int obsQreAnswer = 0;
  String _obsQrlAnswer = '';
  String get obsQrlAnswer => _obsQrlAnswer;
  void set obsQrlAnswer(String value) {
    _obsQrlAnswer = value;
    notifyListeners();
  }

  final OfflineGameService offlineGameService = OfflineGameService();
  final RealGameService realGameService = RealGameService();
  final SocketService socketService = SocketService();

  int get timer {
    return this.isOfflineMode
        ? this.offlineGameService.timer.time
        : this.realGameService.timer;
  }

  int get playerScore {
    return this.offlineGameService.playerScore;
  }

  bool get isBonus {
    return this.offlineGameService.isBonus;
  }

  QuizQuestion? get question {
    return this.isOfflineMode
        ? this.offlineGameService.question
        : this.realGameService.question;
  }

  QuizQuestion get oldQuestion {
    return this.isOfflineMode
        ? this.offlineGameService.oldQuestion
        : this.realGameService.oldQuestion;
  }

  int get questionNumber {
    return this.isOfflineMode
        ? this.offlineGameService.currQuestionIndex + 1
        : this.realGameService.questionNumber;
  }

  String get username {
    return this.realGameService.username;
  }

  bool get lockedStatus {
    return this.isOfflineMode
        ? this.offlineGameService.locked
        : this.realGameService.locked;
  }

  bool get validatedStatus {
    return this.isOfflineMode
        ? this.offlineGameService.validated
        : this.realGameService.validated;
  }

  AudioPlayer get audio {
    return this.realGameService.audio;
  }

  void destroy() {
    this.reset();
    this.answers.clear();
  }

  void init(String pathId,[bool isObserver=false]) {
    if (isObserver) this.isObserverMode = true;
    // TODO: add configurations for observer
    if (!this.isOfflineMode) {
      configureBaseSockets();
      this.realGameService.roomId = int.parse(pathId);
      this.realGameService.init();
    } else {
      this.offlineGameService.quizId = pathId;
      this.offlineGameService.init();
    }
  }

  void selectChoice(int index) {
    if (!this.lockedStatus) {
      if (this.answers.containsKey(index)) {
        this.answers.remove(index);
        this.realGameService.sendSelection(index, false);
      } else {
        String? textChoice = this.question?.choices?[index].text;
        this.answers[index] = textChoice;
        this.realGameService.sendSelection(index, true);
      }
    }
  }

  void obsUpdateChoice(int index, bool isSelected) {
    if (this.lockedStatus) return;
    if (isSelected && !this.answers.containsKey(index)) {
      String? textChoice = this.question?.choices?[index].text;
      this.answers[index] = textChoice;
      notifyListeners();
      return;
    }
    if (this.answers.containsKey(index)) {
      this.answers.remove(index);
      notifyListeners();
    }
  }

  void selectQREanswer(int selectedAnswer) {
    if (this.lockedStatus || this.isObserverMode) return;
    this.qreAnswer = selectedAnswer;
    this.realGameService.sendQRESelection(selectedAnswer);
  }

  void selectChoiceOffline(int index) {
    if (this.answers.containsKey(index)) {
      this.answers.remove(index);
    } else {
      String? textChoice = this.question?.choices?[index].text;
      this.answers[index] = textChoice;
    }
  }

  void sendAnswer() {
    if (!this.isOfflineMode) {
      this.realGameService.answers = this.answers;
      this.realGameService.qreAnswer = this.qreAnswer;
      this.realGameService.qrlAnswer = this.qrlAnswer;
      this.realGameService.sendAnswer();
      this.isActive = false;
      this.hasInteracted = false;
    } else {
      this.offlineGameService.answers = this.answers;
      this.offlineGameService.qrlAnswer = this.qrlAnswer;
      this.qrlAnswer = '';
      print('ANSWERS: ${this.answers}');
      this.offlineGameService.sendAnswer();
    }
    this.lastQrlScore = null;
    if (!this.isObserverMode) {
      this.socketService.sendMessage(SocketEvent.GET_LAST_QRL_STATUS, {
        'roomId': this.realGameService.roomId,
        'lastQRLScore': this.lastQrlScore,
        'qrlAnswer': this.qreAnswer,
        'userId': LoggedInUserService.instance.user?.uid
      }); // Done
    }
    this.answers.clear();
  }

  bool isPanicDisabled() {
    if (this.question?.type != null) {
      return this.timer > 20 || this.realGameService.inTimeTransition;
    } else {
      return this.timer > 10 || this.realGameService.inTimeTransition;
    }
  }

  void reset() {
    this.isOfflineMode = false;
    this.isInputFocused = false;
    this.qrlAnswer = '';
    this.isActive = false;
    this.hasInteracted = false;
    this.audio.pause();
    this.audio.seek(Duration.zero);
    this.realGameService.destroy();
    this.offlineGameService.reset();
    this.gotNotified = false;
    this.isQuitBtn = false;
    this.isObserverMode = false;
    this.lastQrlScore = null;
    this.qreAnswer = 0;
  }

  void configureBaseSockets() {
    this.socketService.onMessage(SocketEvent.TIME, (timeValue) {
      handleTimeEvent(timeValue);
      notifyListeners();
    });
  }

  void handleTimeEvent(timeValue) {
    this.realGameService.timer = timeValue;
    if (this.timer == 0 && !this.realGameService.locked) {
      // sendQREAnswer not done??
      this.realGameService.locked = true;
      if (this.username != 'host' && !this.isObserverMode) sendAnswer();
    }
  }
}
