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
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
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
        width: 250,
        height: 180,
        child: Column(
        children: [
        Center(
          child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
            return Text(
              'Vous observer :',
              style: TextStyle(fontSize: 18.0),
            );
            }
            },
            ),
          ],
          ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: SmartAvatar(userId: observationService.observedUid, interactible: false, hasName: true,),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            openSelectorDialog();
          },
          child: Text(
            'Choisir un joueur',
            style: TextStyle(color: Colors.white),
          ),
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
              width: 400, // Increased width
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
              gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8.0, // Reduced blur radius
                offset: const Offset(0, 2),
              ),
              ],
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                'Menu Observation',
                style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 2.0),
              Divider(
                thickness: 1.0,
                color: Colors.blue.shade100,
              ),
              ],
              ),
              ),
            )
        ],
      ),
    );
  }
}