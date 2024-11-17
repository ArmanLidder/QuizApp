import 'package:polyquiz/models/quiz.dart';

class InitialQuestionData {
  final QuizQuestion question;
  final String username;
  final int index;
  final int numberOfQuestions;

  InitialQuestionData({
    required this.question,
    required this.username,
    required this.index,
    required this.numberOfQuestions,
  });
}
