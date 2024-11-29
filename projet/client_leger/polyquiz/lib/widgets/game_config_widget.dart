import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/pages/waiting_room_screen.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/quiz_service.dart';

class GameConfigWidget extends StatefulWidget {
  final Quiz quiz;
  const GameConfigWidget({
    Key? key,
    required this.quiz,
  }) : super(key: key);
  @override
  _GameConfigWidgetState createState() => _GameConfigWidgetState();
}

class _GameConfigWidgetState extends State<GameConfigWidget> {
  final _formKey = GlobalKey<FormState>();

  String _gameType = 'classic';
  int _price = 0;
  bool _friendsOnly = false;
  bool _private = false;
  int _prestige = 0;
  bool _IsAIOn = false;
  final ThemeService themeService = ThemeService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;
  Map get configText => TranslationService.instance.text['GAME_CONFIG_DIALOG'];
  final QuizService quizService = QuizService();
  Map get text => TranslationService.instance.text;

  @override
  Widget build(BuildContext context) {
    final gameConfigService = Provider.of<GameConfigService>(context);

    return Container(
      color: themeService.mainBackground.value,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(configText['CONFIGURE_GAME'],
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeService.secondaryBackground.value)),
              Divider(color: Color.fromRGBO(227, 242, 253, 1)),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                dropdownColor: themeService.mainBackground.value,
                value: _gameType,
                decoration: InputDecoration(
                    labelText: configText['GAME_TYPE_LABEL'],
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeService.mainAccent.value),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: themeService.mainAccent.value))),
                items: [
                  DropdownMenuItem(
                      value: 'classic',
                      child: Text(configText['CLASSIC'],
                          style:
                              TextStyle(color: themeService.mainAccent.value))),
                  DropdownMenuItem(
                      value: 'equipe',
                      child: Text(configText['TEAM'],
                          style:
                              TextStyle(color: themeService.mainAccent.value))),
                ],
                onChanged: (value) {
                  setState(() {
                    _gameType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return configText['GAME_TYPE_REQUIRED'];
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: "0",
                decoration: InputDecoration(
                    labelText: configText['PRICE_LABEL'],
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeService.mainAccent.value),
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                style: TextStyle(color: themeService.mainAccent.value),
                onChanged: (value) {
                  setState(() {
                    _price = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return configText['PRICE_INVALID'];
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      child: CheckboxListTile(
                        title: Text(configText['FRIENDS_ONLY_LABEL']),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: themeService.secondaryBackground.value,
                        value: _friendsOnly,
                        onChanged: (value) {
                          setState(() {
                            _friendsOnly = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                    child: Container(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      child: CheckboxListTile(
                        title: Text(configText['PRIVATE_GAME_LABEL']),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: themeService.secondaryBackground.value,
                        value: _private,
                        onChanged: (value) {
                          setState(() {
                            _private = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Flexible(
                    child: Container(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      child: CheckboxListTile(
                        title: Text(configText['IA_CORRECTION']),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: themeService.secondaryBackground.value,
                        value: _IsAIOn,
                        onChanged: (value) {
                          setState(() {
                            _IsAIOn = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                dropdownColor: themeService.mainBackground.value,
                focusColor: themeService.mainAccent.value,
                value: _prestige,
                decoration: InputDecoration(
                    labelText: configText['MIN_PRESTIGE_LABEL'],
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeService.mainAccent.value),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: themeService.mainAccent.value))),
                items: [
                  DropdownMenuItem(
                      value: 0,
                      child: Text(
                        configText['NONE'],
                        style: TextStyle(color: themeService.mainAccent.value),
                      )),
                  DropdownMenuItem(
                      value: 50,
                      child: Text(
                        configText['BRONZE'],
                        style: TextStyle(color: themeService.mainAccent.value),
                      )),
                  DropdownMenuItem(
                      value: 100,
                      child: Text(
                        configText['SILVER'],
                        style: TextStyle(color: themeService.mainAccent.value),
                      )),
                  DropdownMenuItem(
                      value: 150,
                      child: Text(
                        configText['GOLD'],
                        style: TextStyle(color: themeService.mainAccent.value),
                      )),
                  DropdownMenuItem(
                      value: 200,
                      child: Text(
                        configText['PLATINUM'],
                        style: TextStyle(color: themeService.mainAccent.value),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _prestige = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return configText['PRESTIGE_REQUIRED'];
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              Divider(color: Color.fromRGBO(227, 242, 253, 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(configText['CANCEL_BUTTON'],
                        style:
                            TextStyle(color: Color.fromRGBO(255, 255, 255, 1))),
                  ),
                  SizedBox(width: 40),
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        backgroundColor:
                            themeService.secondaryBackground.value),
                    onPressed: () async {
                      this.loggedInUserService.reloadUser();
                      this.userData = this.loggedInUserService.getUser();
                      try{
                        final reverification = await quizService.fetchQuizById(widget.quiz!.id);
                        if(reverification != null){
                          if(reverification.visible == false && reverification.owner != userData!.uid){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(text['GAME_ADMIN']['QUIZ_INVISIBLE'])),
                            );
                            return;
                          }
                        }
                        else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(text['GAME_ADMIN']['QUIZ_DELETED'])),
                          );
                          return;
                        }
                      }
                      catch(e){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(text['GAME_ADMIN']['QUIZ_DELETED'])),
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        print('got into validate if');
                        print(_IsAIOn);
                        gameConfigService.setIA(_IsAIOn);
                        gameConfigService.setGameType(_gameType);
                        gameConfigService.setPrice(_price);
                        gameConfigService.setFriendsOnly(_friendsOnly);
                        gameConfigService.setPrivacy(_private);
                        gameConfigService.setPrestige(_prestige);
                        gameConfigService.setUser(this.userData!);
                        Navigator.of(context).pop(); // Close the dialog

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WaitingRoomScreen(
                              quiz: widget.quiz,
                              username:
                                  'nothing', // Pass the username to the waiting room.
                              isHost: true, // This user is not the host.
                              gameConfigService: gameConfigService,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      configText['CREATE_GAME_BUTTON'],
                      style:
                          TextStyle(color: themeService.secondaryAccent.value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
