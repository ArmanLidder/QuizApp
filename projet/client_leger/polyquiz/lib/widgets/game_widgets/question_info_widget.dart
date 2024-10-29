import 'package:flutter/material.dart';
import 'package:polyquiz/services/tts_service.dart';

class QuestionInfoWidget extends StatefulWidget {
  final int questionNum;
  final int questionPts;
  final String questionText;

  const QuestionInfoWidget({
    Key? key,
    required this.questionNum,
    required this.questionPts,
    required this.questionText,
  }) : super(key: key);

  @override
  State<QuestionInfoWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<QuestionInfoWidget> {
  TtsService _ttsService = TtsService();
  IconData ttsDisabledIcon = Icons.voice_over_off_outlined;
  IconData ttsEnabledIcon = Icons.record_voice_over_outlined;
  IconData ttsStateIcon = Icons.voice_over_off_outlined;
  late String _currentQuestionText;
  @override
  void initState() {
    super.initState();
    _ttsService.initTts();
    _currentQuestionText = widget.questionText;
    _ttsService.speak(_currentQuestionText);
  }

  @override
  void didUpdateWidget(QuestionInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionText != oldWidget.questionText) {
      _currentQuestionText = widget.questionText;
      _ttsService.speak(_currentQuestionText);
    }
  }

  @override
  void dispose() {
    _ttsService.resetTts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.all(30.0), // to center the text
      child: Column(
        children: [
          Text(
            'Q${widget.questionNum}',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text('${widget.questionPts} pts', style: TextStyle(fontSize: 16)),
          Text(
            '${widget.questionText}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (ttsStateIcon == ttsDisabledIcon) {
                        ttsStateIcon = ttsEnabledIcon;
                        _ttsService.isTtsEnabled = true;
                        _ttsService.speak(widget.questionText);
                      } else {
                        ttsStateIcon = ttsDisabledIcon;
                        _ttsService.isTtsEnabled = false;
                        _ttsService.stop();
                      }
                    });
                  },
                  icon: Icon(ttsStateIcon)),
              IconButton(
                  onPressed: () {
                    _ttsService.speak(_currentQuestionText);
                  },
                  icon: Icon(Icons.play_arrow_outlined)),
              IconButton(
                  onPressed: () {
                    _ttsService.stop();
                  },
                  icon: Icon(Icons.stop)),
            ],
          )
        ],
      ),
    );
  }
}
