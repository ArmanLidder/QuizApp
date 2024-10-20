import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/offline_game_service.dart';
import 'package:polyquiz/services/real_game_service.dart';
import 'package:polyquiz/services/socket_service.dart';

class GameService {
  bool isTestMode = false;
  bool isInputFocused = false;
  Map<int, String?> answers = {};
  String qrlAnswer = '';
  bool isHostEvaluating = false;
  bool isActive = false;
  bool hasInteracted = false;
  int? lastQrlScore;

  final OfflineGameService _offlineGameService = OfflineGameService();
  final RealGameService _realGameService = RealGameService();
  final SocketService socketService = SocketService();

  // int get timer {
  //   return isTestMode ? _offlineGameService.timer?.time ?? 0 : _realGameService.timer;
  // }

  int get playerScore {
    return _offlineGameService.playerScore;
  }

  bool get isBonus {
    return _offlineGameService.isBonus;
  }

  QuizQuestion? get question {
    return isTestMode
        ? _offlineGameService.question
        : _realGameService.question;
  }

  int get questionNumber {
    return isTestMode
        ? _offlineGameService.currQuestionIndex + 1
        : _realGameService.questionNumber;
  }

  String get username {
    return _realGameService.username;
  }

  bool get lockedStatus {
    return isTestMode ? _offlineGameService.locked : _realGameService.locked;
  }

  bool get validatedStatus {
    return isTestMode
        ? _offlineGameService.validated
        : _realGameService.validated;
  }

  // Audio get audio {
  //   return _realGameService.audio;
  // }

  void destroy() {
    reset();
    answers.clear();
  }

  void init(String pathId) {
    if (!isTestMode) {
      //configureBaseSockets();
      _realGameService.roomId = int.parse(pathId);
      _realGameService.init();
    } else {
      _offlineGameService.quizId = pathId;
      _offlineGameService.init();
    }
  }

  void selectChoice(int index) {
    if (!lockedStatus) {
      if (answers.containsKey(index)) {
        answers.remove(index);
        _realGameService.sendSelection(index, false);
      } else {
        String? textChoice = question?.choices?[index].text;
        answers[index] = textChoice;
        _realGameService.sendSelection(index, true);
      }
    }
  }

  void sendAnswer() {
    if (!isTestMode) {
      _realGameService.answers = answers;
      _realGameService.qrlAnswer = qrlAnswer;
      _realGameService.sendAnswer();
      isActive = false;
      hasInteracted = false;
    } else {
      _offlineGameService.answers = answers;
      _offlineGameService.qrlAnswer = qrlAnswer;
      qrlAnswer = '';
      _offlineGameService.sendAnswer();
    }
    lastQrlScore = null;
    answers.clear();
  }

  // bool isPanicDisabled() {
  //   if (question?.type != null) {
  //     return timer > QLR_PANIC_MODE_ENABLED || _realGameService.inTimeTransition;
  //   } else {
  //     return timer > QCM_PANIC_MODE_ENABLED || _realGameService.inTimeTransition;
  //   }
  // }

  void reset() {
    isTestMode = false;
    qrlAnswer = '';
    isActive = false;
    hasInteracted = false;
    //audio.pause();
    //audio.currentTime = 0;
    _realGameService.destroy();
    _offlineGameService.reset();
  }

  // void configureBaseSockets() {
  //   socketService.onMessage(SocketEvent.TIME, (dynamic timeValue) {
  //     handleTimeEvent(timeValue);
  //   });
  // }

  // void handleTimeEvent(dynamic timeValue) {
  //   _realGameService.timer = timeValue;
  //   if (timer == 0 && !_realGameService.locked) {
  //     _realGameService.locked = true;
  //     if (username != HOST_USERNAME) sendAnswer();
  //   }
  // }
}
