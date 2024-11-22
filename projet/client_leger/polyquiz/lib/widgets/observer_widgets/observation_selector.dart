import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/observer_widgets/observation_list_widget.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
import 'package:polyquiz/main.dart';

class ObservationSelector extends StatefulWidget {
  @override
  _ObservationSelectorState createState() => _ObservationSelectorState();
}

class _ObservationSelectorState extends State<ObservationSelector> {
  bool isMenuOpen = false;
  ObservationService observationService = ObservationService.instance;

  void toggleMenu() {
    open(context);
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }


  void openSelectorDialog() {
    toggleMenu();
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            Dialog(
              child: Container(
                width: 700,
                height: 700,
                child: ObservationListWidget(),
              ),
            )
    ).then((result) {
      if (result != null) {
        setState(() {
          observationService.observedUid = result;
        });
      }
    });
  }

  void open(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            Dialog(
              child: Container(
                width: 600,
                height: 200,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye),
                          SizedBox(width: 8.0),
                            FutureBuilder(
                            future: userService.getUserById(observationService.observedUid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                              } else {
                              return Text('Vous observer : ${snapshot.data!.username}');
                              }
                            },
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: SmartAvatar(userId: observationService.observedUid, interactible: false, hasName: true,),
                    ),
                    ElevatedButton(
                      onPressed: openSelectorDialog,
                      child: Text('Choisir un joueur'),
                    ),
                  ],
                ),
              ),
            )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: toggleMenu,
            child: Container(
              color: Colors.grey,
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Icon(isMenuOpen
                  //     ? Icons.expand_more
                  //     : Icons.chevron_right),
                  SizedBox(width: 8.0),
                  Text('Menu Observation'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}