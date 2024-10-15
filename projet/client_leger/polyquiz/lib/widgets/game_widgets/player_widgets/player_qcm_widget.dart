import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_choice_widget.dart';

class PlayerQcm extends StatefulWidget {
  const PlayerQcm({super.key});

  @override
  State<PlayerQcm> createState() => _PlayerQcmWidgetState();
}

class _PlayerQcmWidgetState extends State<PlayerQcm> {
  List<String> choices = ['choice1', 'choice2', 'choice3'];
  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.all(10.0),
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(choices.length, (index) {
        return PlayerQcmChoice(index: index, choice: choices[index]);
      }),
    );
  }
}
