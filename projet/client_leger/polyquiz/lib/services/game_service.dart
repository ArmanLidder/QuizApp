import 'package:polyquiz/models/player.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GameService {
  static final GameService _instance = GameService._internal();

  GameService._internal();

  factory GameService() {
    return _instance;
  }

  String username = '';
  num roomId = 0;
  List<Player> players = [];
  Map<int, String?> answers = {};
  int questionNumber = 1;
  int timer = 1;
  QuizQuestion? question = null;
  bool isLast = false;
  bool locked = false;
  bool validated = false;
  String qrlAnswer = '';
  //late final Audio audio = Audio('assets/music.mp3');
  bool audioPaused = false;
  bool inTimeTransition = false;
}
