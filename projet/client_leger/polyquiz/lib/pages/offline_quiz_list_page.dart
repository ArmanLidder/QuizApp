import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/services/game_service.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/quiz_file_service.dart';
import 'package:polyquiz/services/translationService.dart';

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
  Quiz? selectedQuiz = null;
  Map get text => TranslationService.instance.text;
  Map get quizSelectText => text['QUIZ_SELECTION'];

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
        title: Text('Quiz'),
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
                              Text(quizSelectText['NO_DOWNLOAD']),
                              TextButton(
                                onPressed: () {
                                  _globalNavigationService.navigateTo('/auth');
                                },
                                child: Text(
                                  TranslationService.instance
                                      .text['CONFIRMATION_DIALOG']['CANCEL'],
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
                        Text(quizSelectText['PAGE_TITLE'],
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
                              child: Text(text['GAME_ADMIN']['QUIZZES'],
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
                                          color: Colors.black, width: 1.0)),
                                  child: ListTile(
                                    tileColor: quiz == selectedQuiz
                                        ? Color.fromRGBO(53, 121, 246, 1)
                                        : Colors.white,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(quiz.title,
                                            style: TextStyle(fontSize: 16)),
                                        IconButton(
                                            iconSize: 35.0,
                                            onPressed: () async {
                                              if (this.selectedQuiz == quiz) {
                                                this.selectedQuiz = null;
                                              }
                                              String message = await this
                                                  ._quizFileService
                                                  .deleteQuiz(quiz);
                                              this.showPopup(context, message);
                                              setState(() {
                                                this.quizzes.remove(quiz);
                                              });
                                            },
                                            icon: Icon(
                                              Icons.delete_forever,
                                              color: Colors.black,
                                            ))
                                      ],
                                    ),
                                    subtitle: quiz == selectedQuiz
                                        ? SingleChildScrollView(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    quiz.title,
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  // Text('Description: ${quiz.description}'),
                                                  RichText(
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                "${quizSelectText['DESCRIPTION']}: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black)),
                                                        TextSpan(
                                                            text: quiz
                                                                .description),
                                                      ])),
                                                  // Text('Durée: ${quiz.duration} s'),
                                                  RichText(
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                "${quizSelectText['DURATION']}: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        TextSpan(
                                                            text:
                                                                "${quiz.duration} ${quizSelectText['DURATION_SUFFIX']}"),
                                                      ])),
                                                  Text(
                                                    quizSelectText[
                                                            'QUESTIONS'] +
                                                        ":",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(), // Disable inner scrolling
                                                    itemCount:
                                                        quiz.questions.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Center(
                                                        child: Text(
                                                            "•" +
                                                                quiz
                                                                    .questions[
                                                                        index]
                                                                    .text,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    onTap: () {
                                      setState(() {
                                        this.selectedQuiz = quiz;
                                      });
                                    },
                                  ),
                                );
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                _gameService.isOfflineMode = true;
                                _gameService.offlineGameService.quiz =
                                    selectedQuiz!;
                                _gameService.offlineGameService.question =
                                    selectedQuiz!.questions[0];
                                _globalNavigationService
                                    .navigateTo('/offlinegame');
                              },
                              child: Text(text['GAME_ADMIN']['PLAY'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20)),
                              style: TextButton.styleFrom(
                                backgroundColor: selectedQuiz != null
                                    ? Color.fromRGBO(53, 121, 246, 1)
                                    : Color.fromRGBO(200, 200, 200, 1),
                              ),
                            ),
                            SizedBox(width: 40),
                            TextButton(
                              onPressed: () {
                                _globalNavigationService.navigateTo('/auth');
                              },
                              child: Text(
                                TranslationService.instance
                                    .text['CONFIRMATION_DIALOG']['CANCEL'],
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
                                  backgroundColor:
                                      Color.fromRGBO(246, 53, 53, 1)),
                            )
                          ],
                        ),
                      ],
                    ),
    );
  }
}
