import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import './waiting_room_screen.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/widgets/game_config_widget.dart';
import '../services/waiting_room_service.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizService quizService = QuizService();
  List<Quiz> quizzes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
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
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: quizzes.length,
                        itemBuilder: (context, index) {
                          final quiz = quizzes[index];
                          return ListTile(
                            title: Text(quiz.title),
                            subtitle:
                                Text('Duration: ${quiz.duration} minutes'),
                            onTap: ()
                              async {
                                final gameConfigService = Provider.of<GameConfigService>(context, listen: false);

                                // Show the GameConfigWidget as a dialog
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: GameConfigWidget(),
                                    );
                                  },
                              );

                              // Pass the quiz and gameConfig as arguments
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WaitingRoomScreen(
                                  quiz: quiz,
                                  username: 'nothing', // Pass the username to the waiting room.
                                  isHost: true, // This user is not the host.
                                  gameConfigService: gameConfigService,
                                ),
                              ),
                            );
                            },
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
