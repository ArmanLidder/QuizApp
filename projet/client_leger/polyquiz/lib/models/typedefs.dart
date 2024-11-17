import 'package:polyquiz/models/quiz.dart';

class TransportStats {
  final List<MapEntry<String, bool>> values;
  final List<MapEntry<String, num>> responses;
  final QuizQuestion question;

  TransportStats(this.values, this.responses, this.question);
  factory TransportStats.fromJson(List<dynamic> json) {
    return TransportStats(
      (json[0] as List).map((entry) => MapEntry(entry[0] as String, entry[1] as bool)).toList(),
      (json[1] as List).map((entry) => MapEntry(entry[0] as String, entry[1] as num)).toList(),
      QuizQuestion.fromJson(json[2]),
    );
  }
  List<dynamic> toJson() => [
    // Convert values to [key, value] array pairs
    values.map((entry) => [entry.key, entry.value]).toList(),
    // Convert responses to [key, value] array pairs
    responses.map((entry) => [entry.key, entry.value]).toList(),
    // Keep question as is since its format matches
    question.toJson(),
  ];
}

typedef TransportStatsFormat = List<TransportStats>;

class QuestionStatistics {
  final Map<String, bool> responsesValues;
  final Map<String, num> responsesNumber;
  final QuizQuestion? question;

  QuestionStatistics(this.responsesValues, this.responsesNumber, this.question);
}

class QrlAnswer {
  final String answers;
  final int time;

  QrlAnswer(this.answers, this.time);
}
