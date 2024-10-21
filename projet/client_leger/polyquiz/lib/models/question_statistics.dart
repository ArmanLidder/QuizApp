import '../constants/question_type.dart';
import 'quiz_interface.dart';

typedef QuestionStatistics = List<dynamic>;

class QuestionStats {
  static const int RESPONSES_VALUES_INDEX = 0;
  static const int RESPONSES_NUMBER_INDEX = 1;
  static const int QUIZ_QUESTION_INDEX = 2;
}

final Map<String, bool> responses1 = {
  'Option A': true,
  'Option B': false,
  'Option C': true,
};

final Map<String, int> numberOfResponses1 = {
  'Option A': 0,
  'Option B': 0,
  'Option C': 0,
};

final Map<String, bool> responses2 = {
  'Option X': true,
  'Option Y': false,
  'Option Z': true,
};

final Map<String, int> numberOfResponses2 = {
  'Option X': 0,
  'Option Y': 0,
  'Option Z': 0,
};

final Map<String, bool> responses3 = {
  'Choice 1': true,
  'Choice 2': false,
  'Choice 3': true,
};

final Map<String, int> numberOfResponses3 = {
  'Choice 1': 0,
  'Choice 2': 0,
  'Choice 3': 0,
};

final QuizQuestion question = QuizQuestion(
  type: QuestionType.QCM,
  text: 'Which of the following options is correct?',
  points: 1,
  choices: [
    QuizChoice(text: 'Option A', isCorrect: true),
    QuizChoice(text: 'Option B', isCorrect: false),
    QuizChoice(text: 'Option C', isCorrect: true),
  ],
);

final QuizQuestion question2 = QuizQuestion(
  type: QuestionType.QCM,
  text: 'Choose the right answer from the following options:',
  points: 1,
  choices: [
    QuizChoice(text: 'Option X', isCorrect: true),
    QuizChoice(text: 'Option Y', isCorrect: false),
    QuizChoice(text: 'Option Z', isCorrect: true),
  ],
);

final QuizQuestion question3 = QuizQuestion(
  type: QuestionType.QCM,
  text: 'Select the correct option from the choices below:',
  points: 1,
  choices: [
    QuizChoice(text: 'Option 1', isCorrect: true),
    QuizChoice(text: 'Option 2', isCorrect: false),
    QuizChoice(text: 'Option 3', isCorrect: true),
  ],
);

final List<QuestionStatistics> mockStats = [
  [responses1, numberOfResponses1, question],
  [responses2, numberOfResponses2, question2],
  [responses3, numberOfResponses3, question3],
];