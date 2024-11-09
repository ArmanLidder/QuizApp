import 'package:flutter/material.dart';
import 'package:polyquiz/models/quiz.dart';
import 'package:polyquiz/pages/waiting_room_screen.dart';
import 'package:provider/provider.dart';
import 'package:polyquiz/services/game_config_service.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/models/game_info_interface.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

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
  double _price = 0.0;
  bool _friendsOnly = false;
  bool _private = true;
  double _prestige = 0.0;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  User? userData;

  @override
  Widget build(BuildContext context) {
    final gameConfigService = Provider.of<GameConfigService>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Configurer la partie', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gameType,
              decoration: InputDecoration(labelText: 'Type de partie'),
              items: [
                DropdownMenuItem(value: 'classic', child: Text('Classique')),
                DropdownMenuItem(value: 'equipe', child: Text('Équipe')),
              ],
              onChanged: (value) {
                setState(() {
                  _gameType = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le type de partie est requis. Veuillez sélectionner un type.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _price = double.tryParse(value) ?? 0.0;
                });
              },
              validator: (value) {
                if (value == null ||
                    double.tryParse(value) == null ||
                    double.parse(value) < 0) {
                  return 'Le prix doit être un entier supérieur ou égal à 0.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Amis Seulement'),
              value: _friendsOnly,
              onChanged: (value) {
                setState(() {
                  _friendsOnly = value!;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Partie privée'),
              value: _private,
              onChanged: (value) {
                setState(() {
                  _private = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    this.userData = this.loggedInUserService.getUser();
                    if (_formKey.currentState!.validate()) {
                      gameConfigService.setGameType(_gameType);
                      gameConfigService.setPrice(_price);
                      gameConfigService.setFriendsOnly(_friendsOnly);
                      gameConfigService.setPrivacy(_private);
                      gameConfigService.setPrestige(_prestige);
                      gameConfigService.setUser(this.userData!);
                      Navigator.of(context).pop(); // Close the dialog
                    }
                    Navigator.push(
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
                  },
                  child: Text('Créer partie'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
