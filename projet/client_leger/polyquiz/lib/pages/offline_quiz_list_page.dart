import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/quiz_file_service.dart';

class OfflineQuizListPage extends StatefulWidget {
  const OfflineQuizListPage({super.key});

  @override
  State<OfflineQuizListPage> createState() => _OfflineQuizListPageState();
}

class _OfflineQuizListPageState extends State<OfflineQuizListPage> {
  final QuizFileService _quizFileService = QuizFileService();
  final GameService _gameService = GameService();
  final GlobalNavigationService _globalNavigationService =
      GlobalNavigationService();
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

  void showPopup(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.0));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : quizzes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Aucun quiz téléchargé"),
                              TextButton(
                                onPressed: () {
                                  _globalNavigationService.navigateTo('/auth');
                                },
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontSize: 20),
                                ),
                                style: TextButton.styleFrom(
                                    textStyle: TextStyle(
                                        fontWeight: FontWeight.normal),
                                    splashFactory: NoSplash.splashFactory,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(246, 53, 53, 1)),
                              )
                            ]),
                      ),
                    )
                  : Column(
                      children: [
                        Text('Sélectionnez un des jeux disponibles :',
                            style: TextStyle(fontSize: 16)),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(53, 121, 246, 1),
                              border: Border.all(
                                  color: const Color.fromRGBO(0, 0, 0, 1),
                                  width: 1.0)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Jeu',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) {
                              final quiz = quizzes[index];
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromRGBO(0, 0, 0, 1),
                                        width: 1.0)),
                                child: ListTile(
                                  title: Text(quiz.title),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Durée: ${quiz.duration} s'),
                                      IconButton(
                                          iconSize: 35.0,
                                          onPressed: () async {
                                            String message = await this
                                                ._quizFileService
                                                .deleteQuiz(quiz);
                                            this.showPopup(context, message);
                                            setState(() {
                                              this.quizzes.remove(quiz);
                                            });
                                          },
                                          icon: Icon(Icons.delete_forever))
                                    ],
                                  ),
                                  onTap: () {
                                    _gameService.isOfflineMode = true;
                                    _gameService.offlineGameService.quiz = quiz;
                                    _gameService.offlineGameService.question =
                                        quiz.questions[0];
                                    _globalNavigationService
                                        .navigateTo('/offlinegame');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _globalNavigationService.navigateTo('/auth');
                          },
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontSize: 20),
                          ),
                          style: TextButton.styleFrom(
                              textStyle:
                                  TextStyle(fontWeight: FontWeight.normal),
                              splashFactory: NoSplash.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
                        )
                      ],
                    ),
    );
  }
}
