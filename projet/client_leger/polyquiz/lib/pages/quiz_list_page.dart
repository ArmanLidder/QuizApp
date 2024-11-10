import 'package:flutter/material.dart';
import 'package:polyquiz/services/quiz_file_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/game_widgets/cancel_btn.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/widgets/game_config_widget.dart';
import 'package:polyquiz/enums/question_type.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizService quizService = QuizService();
  final QuizFileService _quizFileService = QuizFileService();
  List<Quiz> quizzes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
    _quizFileService.setUpService();
  }

  Future<void> fetchQuizzes() async {
    try {
      List<Quiz> fetchedQuizzes = await quizService.fetchAllQuizzes();
      setState(() {
        quizzes = fetchedQuizzes;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  void showPopup(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.0));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _areAllQuestionsQCM(Quiz quiz) {
    bool result =
        !quiz.questions.any((question) => question.type != QuestionType.QCM);

    print(quiz.title);
    print(result);
    return result;
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
              : Stack(children: [
                  Column(
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
                                title: Text(quiz.title,
                                    style: TextStyle(fontSize: 16)),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Durée: ${quiz.duration} s'),
                                    if (_areAllQuestionsQCM(quiz))
                                      IconButton(
                                        iconSize: 35.0,
                                        onPressed: () async {
                                          String message =
                                              await _quizFileService
                                                  .downloadQuiz(quiz);
                                          showPopup(context, message);
                                        },
                                        icon: Icon(Icons.download),
                                      )
                                  ],
                                ),
                                onTap: () async {
                                  final gameConfigService =
                                      Provider.of<GameConfigService>(context,
                                          listen: false);

                                  // Show the GameConfigWidget as a dialog
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        child: GameConfigWidget(
                                          quiz: quiz,
                                        ),
                                      );
                                    },
                                  );

                                  // Pass the quiz and gameConfig as arguments
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => WaitingRoomScreen(
                                  //       quiz: quiz,
                                  //       username:
                                  //           'nothing', // Pass the username to the waiting room.
                                  //       isHost: true, // This user is not the host.
                                  //       gameConfigService: gameConfigService,
                                  //     ),
                                  //   ),
                                  // );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      CancelBtn(),
                    ],
                  ),
                  Positioned(bottom: 20, left: 20, child: ChatPopup())
                ]),
    );
  }
}
