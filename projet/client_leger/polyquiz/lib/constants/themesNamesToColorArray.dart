import 'package:flutter/material.dart';

Map<String, List<Color>> themeColors = {
  "light": [
    Colors.white, // mainBackground
    Colors.black, // mainAccent
    Color(0xFF2196F3), // secondaryBackground
    Colors.white, // secondaryAccent
    const Color.fromARGB(255, 234, 232, 232), // container
  ],
  "dark": [
    Color.fromRGBO(43, 48, 59, 1), // mainBackground
    Colors.white, // mainAccent
    Color(0xFF2196F3), // secondaryBackground
    Colors.black, // secondaryAccent
    Color.fromRGBO(26, 29, 36, 1), // container
  ],
  "disco": [
    Color.fromRGBO(25, 25, 66, 1),
    Color.fromRGBO(255, 221, 51, 1),
    Color.fromRGBO(220, 48, 133, 1),
    Color.fromRGBO(178, 229, 255, 1),
    Color.fromRGBO(48, 48, 86, 1),
  ],
  "pinkGrey": [
    Colors.blueGrey[900]!, // mainBackground:
    Colors.blueGrey[50]!, // mainAccent:
    Colors.purple[600]!, // secondaryBackground:
    Colors.purple[200]!, // secondaryAccent:
    Color.fromRGBO(191, 159, 223, 1) // container
  ],
};
