import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';
import 'package:polyquiz/constants/constants.dart';

class QuizService {
  static final String baseUrl = IP_URL + '/api';

  Future<List<Quiz>> fetchAllQuizzes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quiz'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);

        return jsonList.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quizzes');
      }
    } catch (e) {
      throw Exception('Failed to load quizzes: $e');
    }
  }

  Future<Quiz> fetchQuizById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/quiz/$id'));

      if (response.statusCode == 200) {
        return Quiz.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quiz');
      }
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }

  Future<void> createQuiz(Quiz quiz) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quiz.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create quiz');
      }
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quiz.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update quiz');
      }
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/quiz/$id'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete quiz');
      }
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  Future<Quiz> basicGetById(String id) {
    return http.get(Uri.parse('$baseUrl/quiz/$id')).then((response) {
      if (response.statusCode == 200) {
        return Quiz.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quiz');
      }
    }).catchError((error) {
      throw Exception('Failed to load quiz: $error');
    });
  }
}
