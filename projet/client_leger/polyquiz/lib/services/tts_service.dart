import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();

  TtsService._internal();

  factory TtsService() {
    return _instance;
  }

  FlutterTts _flutterTts = FlutterTts();
  Map<dynamic, dynamic> _currentVoice = {};
  bool isTtsEnabled = false;
  //il faudra import le user service pour savoir la langue a utiliser ou la passer en param

  void initTts() {
    this._flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices =
            _voices.where((voice) => voice['name'].contains('en')).toList();
        this._currentVoice = _voices.first;
        print(_currentVoice);
        this.setVoice(_currentVoice);
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    this
        ._flutterTts
        .setVoice({'name': voice['name'], 'locale': voice['locale']});
  }

  void speak(String text) async {
    if (isTtsEnabled) {
      await this._flutterTts.speak(text);
      print('SOUND SHOULD HAVE PLAYED');
    }
  }

  void stop() async {
    if (this.isTtsEnabled) {
      await this._flutterTts.stop();
    }
  }

  void toggleEnable() {
    this.isTtsEnabled = !this.isTtsEnabled;
  }

  void resetTts() {
    this.isTtsEnabled = false;
    this._currentVoice = {};
  }
}
