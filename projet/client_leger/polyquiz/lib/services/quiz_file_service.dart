import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:polyquiz/models/quiz.dart';

class QuizFileService {
  static final QuizFileService _instance = QuizFileService._internal();

  QuizFileService._internal();

  factory QuizFileService() {
    return _instance;
  }

  late final Directory appDocumentsDir;
  late final Directory folder;
  late final String path;

  void setUpService() async {
    this.appDocumentsDir = await getApplicationDocumentsDirectory();
    this.path = "${appDocumentsDir.path}/PolyQuiz";
    print("PATH: ${this.path}");
    this.folder = Directory(path);
    if (!await this.folder.exists()) {
      await folder.create(recursive: true);
    }
  }

  Future<String> downloadQuiz(Quiz quiz) async {
    try {
      final String quizName = quiz.title.replaceAll(' ', '_');
      final File file = File('${this.path}/${quizName}.json');
      if (await file.exists()) {
        return "Le quiz a déjà été téléchargé";
      }
      String fileContent = jsonEncode(quiz.toJson());
      await file.writeAsString(fileContent);
      return "Téléchargement réussi";
    } catch (e) {
      return "Erreur : ${e}";
    }
  }

  Future<List<Quiz>> getQuizzes() async {
    List<Quiz> quizzes = <Quiz>[];
    try {
      final files = this.folder.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith(".json")) {
          try {
            String fileContent = await file.readAsString();
            print('FILE CONTENT: ${fileContent}');
            Quiz quiz = Quiz.fromJson(jsonDecode(fileContent));
            quizzes.add(quiz);
          } on Exception catch (e) {
            print('ERROR WHILE TRANSFORMING JSON TO QUIZ: ${e}');
          }
        }
      }
      return quizzes;
    } catch (e) {
      print("ERROR WHILE GETTING QUIZZES FROM DIRECTORY: ${e}");
      return quizzes;
    }
  }
}
