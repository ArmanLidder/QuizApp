import 'package:polyquiz/models/quiz.dart';

class NextQuestionData {
  final QuizQuestion question;
  final int index;
  final bool isLast;

  NextQuestionData({
    required this.question,
    required this.index,
    required this.isLast,
  });
}
