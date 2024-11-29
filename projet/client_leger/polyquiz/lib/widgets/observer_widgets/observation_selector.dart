import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/observer_widgets/observation_list_widget.dart';
import 'package:polyquiz/services/observation_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';
import 'package:polyquiz/main.dart';
import 'package:polyquiz/services/translationService.dart';

class ObservationSelector extends StatefulWidget {
  @override
  _ObservationSelectorState createState() => _ObservationSelectorState();
}

class _ObservationSelectorState extends State<ObservationSelector> {
  bool isMenuOpen = false;

  ObservationService observationService = ObservationService.instance;
  ThemeService themeService = ThemeService.instance;

  Map get observerText => TranslationService.instance.text['OBSERVER'];
  String get menuText => observerText["OBSERVATION_MENU"];
  String get observText => observerText["OBSERVING"];
  String get titleText => observerText["CHOOSE_PLAYER"];

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
        builder: (BuildContext context) => Dialog(
              child: Container(
                width: 400,
                height: 700,
                child: ObservationListWidget(),
              ),
            )).then((result) {
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
        builder: (BuildContext context) => Dialog(
          backgroundColor: themeService.mainBackground.value,
              child: Container(
                width: 250,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: themeService.mainBackground.value,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_red_eye, color: themeService.mainAccent.value,),
                            SizedBox(width: 8.0),
                            FutureBuilder(
                              future: userService
                                  .getUserById(observationService.observedUid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Text(
                                    menuText,
                                    style: TextStyle(fontSize: 18.0, color: themeService.mainAccent.value),
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
                      child: SmartAvatar(
                        userId: observationService.observedUid,
                        interactible: false,
                        hasName: true,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeService.secondaryBackground.value,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        openSelectorDialog();
                      },
                      child: Text(
                        titleText,
                        style: TextStyle(color: themeService.secondaryAccent.value),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 40,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.white, width: 2.0),
      ),
      child: Container(
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
                    colors: [themeService.secondaryBackground.value, themeService.secondaryBackground.value],
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
                      menuText,
                      style: TextStyle(
                        color: themeService.secondaryAccent.value,
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
      ),
    );
  }
}
