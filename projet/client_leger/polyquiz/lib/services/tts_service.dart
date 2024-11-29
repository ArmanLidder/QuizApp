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
  String _currentLanguage = 'fr';
  //il faudra import le user service pour savoir la langue a utiliser ou la passer en param
  void setVoice(Map voice) async {
    await this
        ._flutterTts
        .setVoice({'name': voice['name'], 'locale': voice['locale']});
  }

  void _updateVoice() {
    this._flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices = _voices
            .where((voice) => voice['locale'].contains(_currentLanguage))
            .toList();
        if (_voices.isNotEmpty) {
          this._currentVoice = _voices.first;
          this.setVoice(_currentVoice);
        } else {
        }
      } catch (e) {
      }
    });
  }

  void initTts(String language) {
    _currentLanguage = language;
    _updateVoice();
  }

  void speak(String text) async {
    if (isTtsEnabled) {
      await this._flutterTts.speak(text);
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
