import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/game_widgets/player_widgets/player_qcm_choice_widget.dart';
import 'package:polyquiz/services/game_interface_management_service.dart';
import 'package:polyquiz/models/quiz.dart';

class PlayerQcm extends StatefulWidget {
  final GameInterfaceManagementService? gameInterfaceManagementService;

  const PlayerQcm({
    Key? key,
    this.gameInterfaceManagementService,
  }) : super(key: key);

  @override
  State<PlayerQcm> createState() => _PlayerQcmWidgetState();
}

class _PlayerQcmWidgetState extends State<PlayerQcm> {
  // late List<QuizChoice> choices;

  @override
  void initState() {
    super.initState();
    // choices = widget.gameInterfaceManagementService?.gameService.question?.choices ?? [];
  }
  Color textBtnColor = Color.fromRGBO(0, 0, 0, 0);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: widget.gameInterfaceManagementService!.gameService,
        builder: (BuildContext context, Widget? snapshot) {   
          return GridView.count(
            padding: EdgeInsets.all(10.0),
            crossAxisCount: 2,
            childAspectRatio: 2,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(widget.gameInterfaceManagementService!.gameService.question!.choices!.length, (index) {
              return PlayerQcmChoice(index: index, choice: widget.gameInterfaceManagementService!.gameService.question!.choices![index].text, gameInterfaceManagementService : widget.gameInterfaceManagementService);
            }),
          );
        }
      )
    );
  }
}
