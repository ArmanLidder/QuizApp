import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/constants/socket-event.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/services/socket_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
import 'package:polyquiz/services/translationService.dart';

class ObservationListWidget extends StatefulWidget {
  const ObservationListWidget({super.key});

  @override
  State<ObservationListWidget> createState() => _ObservationListWidgetState();
}

class _ObservationListWidgetState extends State<ObservationListWidget> {
  // LES VALEURS DE TEXTES
  Map get observerText => TranslationService.instance.text['OBSERVER'];
  String get titleText => observerText["CHOOSE_PLAYER"];
  String get observeButtonText => observerText["OBSERVE"];
  String get cancelButtonText => observerText["CANCEL"];

  // SERVICES
  final observationService = ObservationService.instance;
  final socketService = SocketService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    receivePlayerList();
    getPlayerList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          children: <Widget>[
            getTitleWidget(),
            Divider(),
            getPlayerListWidget(),
            Divider(),
            getCancelButton()
          ]
      ),
    );
  }

  Widget getTitleWidget() {
    return Center(
      child: Text(
      titleText,
      style: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.bold,
      ),
      ),
    );
  }

  Widget getPlayerListWidget() {
    return Obx(() {
      return Expanded(
      child: Center(
        child: ListView.builder(
          itemCount: observationService.playerList.length,
          itemBuilder: (BuildContext context, int index) => getPlayerTile(observationService.playerList[index])
        ),
      ),
      );
    });
  }

  Widget getPlayerTile(String uid) {
    Widget observeButton = TextButton(
      onPressed: () { 
        this.observationService.observedUid = uid;
        observationService.observeOtherPlayer(uid); 
        Navigator.of(context).pop();
        },
      child: Text(
        observeButtonText,
        style: TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
      ),
    );

    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SmartAvatar(userId: uid, interactible: false, hasName: true,),
            SizedBox(width: 10),
            observeButton
          ],
        ),
      ),
    );
  }

  Widget getCancelButton() {
    return Center(
      child: TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      }, 
      child: Text(
        cancelButtonText,
        style: TextStyle(color: Colors.red),
      ),
      style: TextButton.styleFrom(
        side: BorderSide(color: Colors.red),
      ),
      ),
    );
  }

  void getPlayerList() {
    this.socketService.sendMessage(SocketEvent.GET_OBSERVER_PLAYER_LIST, this.observationService.gameConfigs!.room);
  }

  void receivePlayerList() {
    this.socketService.onMessage(SocketEvent.SENDING_OBSERVER_PLAYER_LIST, (data) {
      List<String> newList = [];
      newList.add(this.observationService.gameConfigs!.hostUserId);
      data.forEach((player) => newList.add(player.toString()));
      newList.remove(this.observationService.observedUid);
      this.observationService.playerList.value = newList;
      print(newList);
    });
  }
}

