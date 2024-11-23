import 'package:flutter/material.dart';
Map<String, List<Color>> themeColors = {
  "light": [
    Colors.white, // mainBackground
    Colors.black, // mainAccent
    Color.fromRGBO(53, 121, 246, 1), // secondaryBackground
    Colors.white, // secondaryAccent
  ],
  "dark": [
    Color.fromRGBO(43, 48, 59, 1), // mainBackground
    Colors.white, // mainAccent
    Color.fromRGBO(53, 121, 246, 1), // secondaryBackground
    Colors.black, // secondaryAccent
  ],
  "disco": [
    Colors.purple[500]!, // mainBackground
    Colors.yellow[500]!, // mainAccent
    Colors.black, // secondaryBackground
    Colors.red[500]!, // secondaryAccent
  ],
  "blueGrey": [
    Colors.blueGrey[900]!, // mainBackground:
    Colors.blueGrey[50]!, // mainAccent:
    Colors.purple[600]!, // secondaryBackground:
    Colors.purple[200]!, // secondaryAccent:
  ],
};
