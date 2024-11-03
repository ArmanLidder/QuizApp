import 'package:polyquiz/enums/question_type.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String? lastModification;
  final List<QuizQuestion> questions;
  final bool? visible;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    this.lastModification,
    required this.questions,
    this.visible,
  });
}

class QuizQuestion {
  final QuestionType type;
  final String text;
  final int points;
  final List<QuizChoice>? choices;

  QuizQuestion({
    required this.type,
    required this.text,
    required this.points,
    this.choices,
  });
}

class QuizChoice {
  final String text;
  final bool? isCorrect;

  QuizChoice({
    required this.text,
    this.isCorrect,
  });
}
