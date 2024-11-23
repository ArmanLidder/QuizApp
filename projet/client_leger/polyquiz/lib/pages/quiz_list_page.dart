import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/quiz_file_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_popup.dart';
import 'package:polyquiz/widgets/game_widgets/cancel_btn.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/widgets/game_config_widget.dart';
import 'package:polyquiz/enums/question_type.dart';
import '../widgets/fancyAppBar.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizService quizService = QuizService();
  final QuizFileService _quizFileService = QuizFileService();
  final ThemeService _themeService = ThemeService.instance;

  List<Quiz> quizzes = [];
  bool isLoading = true;
  String errorMessage = '';
  Quiz? selectedQuiz = null;
  final ThemeService themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  Map get quizSelectText => text['QUIZ_SELECTION'];

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
        content: Text(message,
            style: TextStyle(color: themeService.mainAccent.value)),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.0));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool _areAllQuestionsQCM(Quiz quiz) {
    bool result =
        !quiz.questions.any((question) => question.type != QuestionType.QCM);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
          backgroundColor: _themeService.mainBackground.value,
          appBar: FancyAppBar(context: context, hasBackButton: false),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Text(
                      errorMessage,
                      style: TextStyle(color: themeService.mainAccent.value),
                    ))
                  : Stack(children: [
                      Column(
                        children: [
                          Text(quizSelectText['PAGE_TITLE'],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: themeService.mainAccent.value)),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                                color: _themeService.secondaryBackground.value,
                                border: Border.all(
                                    color: _themeService.mainAccent.value,
                                    width: 1.0)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(text['GAME_ADMIN']['QUIZZES'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _themeService.mainBackground.value,
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
                                          color: _themeService.mainAccent.value,
                                          width: 1.0)),
                                  child: ListTile(
                                    tileColor: quiz == selectedQuiz
                                        ? themeService.secondaryBackground.value
                                        : themeService.mainBackground.value,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(quiz.title,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: themeService
                                                    .mainAccent.value)),
                                        if (_areAllQuestionsQCM(quiz))
                                          IconButton(
                                            color:
                                                themeService.mainAccent.value,
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
                                    subtitle: quiz == selectedQuiz
                                        ? SingleChildScrollView(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: themeService
                                                      .mainBackground.value,
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
                                                        color: themeService
                                                            .mainAccent.value),
                                                  ),
                                                  // Text('Description: ${quiz.description}'),
                                                  RichText(
                                                      text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                "${quizSelectText['DESCRIPTION']}: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: themeService
                                                                    .mainAccent
                                                                    .value)),
                                                        TextSpan(
                                                            style: TextStyle(
                                                                color: themeService
                                                                    .mainAccent
                                                                    .value),
                                                            text: quiz
                                                                .description),
                                                      ])),
                                                  // Text('Durée: ${quiz.duration} s'),
                                                  RichText(
                                                      text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                        TextSpan(
                                                            text:
                                                                "${quizSelectText['DURATION']}: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: themeService
                                                                    .mainAccent
                                                                    .value)),
                                                        TextSpan(
                                                            style: TextStyle(
                                                                color: themeService
                                                                    .mainAccent
                                                                    .value),
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
                                                        color: themeService
                                                            .mainAccent.value),
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
                                                                color: themeService
                                                                    .mainAccent
                                                                    .value)),
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
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  if (selectedQuiz != null) {
                                    final gameConfigService =
                                        Provider.of<GameConfigService>(context,
                                            listen: false);

                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          child: GameConfigWidget(
                                            quiz: selectedQuiz!,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text(text['GAME_ADMIN']['PLAY'],
                                    style: TextStyle(
                                        color:
                                            _themeService.secondaryAccent.value,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20)),
                                style: TextButton.styleFrom(
                                  backgroundColor: selectedQuiz != null
                                      ? Color.fromRGBO(53, 121, 246, 1)
                                      : Color.fromRGBO(200, 200, 200, 1),
                                ),
                              ),
                              SizedBox(width: 40),
                              CancelBtn(),
                            ],
                          ),
                        ],
                      ),
                      Positioned(bottom: 20, left: 20, child: ChatPopup())
                    ]));
    });
  }
}
