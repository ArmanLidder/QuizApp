import 'package:polyquiz/enums/question_type.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final int duration;
  final String? lastModification;
  final List<QuizQuestion> questions;
  final bool? visible;
  final String? owner;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    this.lastModification,
    required this.questions,
    this.visible,
    this.owner,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      duration: json['duration'] is int
          ? json['duration']
          : int.parse(json['duration']),
      lastModification: json['lastModification'] as String?,
      questions: (json['questions'] as List<dynamic>)
          .map((question) => QuizQuestion.fromJson(question))
          .toList(),
      visible: json['visible'] as bool?,
      owner: json['owner'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'lastModification': lastModification,
      'questions': questions.map((q) => q.toJson()).toList(),
      'visible': visible,
      'owner': owner,
    };
  }
}

class Interval {
  final num max;
  final num min;

  Interval({required this.min, required this.max});

  factory Interval.fromJson(Map<String, dynamic> data) {
    return Interval(
        min: data['min'] as num,
        max: data['max'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max': max,
      'min': min,
    };
  }
}

class QuizQuestion {
  final QuestionType type;
  final String text;
  final int points;
  final List<QuizChoice>? choices;
  final num? answer;
  final Interval? interval;
  final num? margin;
  final String? imageUrl;

  QuizQuestion({
    required this.type,
    required this.text,
    required this.points,
    this.choices,
    this.answer,
    this.interval,
    this.margin,
    this.imageUrl,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      type: QuestionType.values[json['type']],
      text: json['text'] as String,
      points: json['points'] as int,
      choices: json['choices'] != null
          ? (json['choices'] as List<dynamic>)
              .map((choice) => QuizChoice.fromJson(choice))
              .toList()
          : null,
      answer: json['answer'] != null
        ? json['answer'] as num : null,
      interval: json['interval'] != null
        ? Interval.fromJson(json['interval']) : null,
      margin: json['margin'] != null
        ? json['margin'] as num : null,
      imageUrl: json['imageUrl'] != null
        ? json['imageUrl'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index, // Store enum as int
      'text': text,
      'points': points,
      'choices': choices?.map((c) => c.toJson()).toList(),
      if (answer != null) 'answer': answer,
      if (interval != null) 'interval': interval!.toJson(),
      if (margin != null) 'margin': margin,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}

class QuizChoice {
  final String text;
  final bool? isCorrect;

  QuizChoice({
    required this.text,
    this.isCorrect,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}
