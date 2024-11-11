import 'package:flutter/material.dart';

Map<String, List<Color>> themeColors = {
  "default": [
    Colors.white,   // mainBackground
    Colors.black,   // mainAccent
    Colors.blue[500]!,    // secondaryBackground
    Colors.white,   // secondaryAccent
  ],
  "dark": [
    Colors.black,   // mainBackground
    Colors.white,   // mainAccent
    Colors.blue[500]!,    // secondaryBackground
    Colors.black,   // secondaryAccent
  ],
  "disco": [
    Colors.purple[500]!,  // mainBackground
    Colors.yellow[500]!,  // mainAccent
    Colors.black,   // secondaryBackground
    Colors.red[500]!,     // secondaryAccent
  ],
};
