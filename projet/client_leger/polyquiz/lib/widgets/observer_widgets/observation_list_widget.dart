import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';

class ObservationListWidget extends StatelessWidget {
  ObservationListWidget({super.key});

  // LES VALEURS DE TEXTES
  final titleText = "Choisir un joueur à observer";
  final observeButtonText = "Observer";
  final cancelButtonText = "Annuler";

  // SERVICES
  final observationService = ObservationService.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          getTitleWidget(),
          getPlayerListWidget(),
          getCancelButton()
        ]
      ),
    );
  }

  Widget getTitleWidget() {
    return Center(
      child: Text(titleText),
    );
  }

  Widget getPlayerListWidget() {
    final playerList = observationService.playerList;
    return ListView.builder(
        itemCount: playerList.length,
        itemBuilder: (BuildContext context, int index) => getPlayerTile(playerList[index])
    );
  }
  
  Widget getPlayerTile(String uid) {
    Widget observeButton = TextButton(
        onPressed: () { observationService.observeOtherPlayer(uid); },
        child: Text(observeButtonText)
    );

    return Container(
      child: Center(
        child: Row(
          children: [
            SmartAvatar(userId: uid, interactible: false, hasName: true,),
            observeButton
          ],
        ),
      ),
    );
  }

  Widget getCancelButton() {
    return Center(
      child: TextButton(onPressed: (){}, child: Text(cancelButtonText)),
    );
  }
}
