import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/quiz_file_service.dart';

class OfflineQuizListPage extends StatefulWidget {
  const OfflineQuizListPage({super.key});

  @override
  State<OfflineQuizListPage> createState() => _OfflineQuizListPageState();
}

class _OfflineQuizListPageState extends State<OfflineQuizListPage> {
  final QuizFileService _quizFileService = QuizFileService();
  List<Quiz> quizzes = [];
  bool isLoading = true;
  String errorMessage = "";

  Future<void> fetchQuizzes() async {
    List<Quiz> fetchedQuizzes = await _quizFileService.getQuizzes();
    setState(() {
      quizzes = fetchedQuizzes;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _quizFileService.setUpService().then((_) {
      fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : quizzes.isEmpty
                  ? Column(children: [
                      Text("Aucun quiz téléchargé"),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text("Retours a la page d'origine"),
                      )
                    ])
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = quizzes[index];
                              return ListTile(
                                title: Text(quiz.title),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Duration: ${quiz.duration} minutes'),
                                    IconButton(
                                        iconSize: 35.0,
                                        onPressed: () {},
                                        icon: Icon(Icons.delete_forever))
                                  ],
                                ),
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: Text("Retours a la page d'origine"),
                        ),
                      ],
                    ),
    );
  }
}
