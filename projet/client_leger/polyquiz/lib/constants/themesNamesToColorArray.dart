import 'package:flutter/material.dart';

Map<String, List<Color>> themeColors = {
  "light": [
    Colors.white, // mainBackground
    Colors.black, // mainAccent
    Color.fromRGBO(53, 121, 246, 1), // secondaryBackground
    Colors.white, // secondaryAccent
    const Color.fromARGB(255, 234, 232, 232), // container
  ],
  "dark": [
    Color.fromRGBO(43, 48, 59, 1), // mainBackground
    Colors.white, // mainAccent
    Color.fromRGBO(0, 123, 255, 1), // secondaryBackground
    Colors.black, // secondaryAccent
    Color.fromRGBO(26, 29, 36, 1), // container
  ],
  "disco": [
    Colors.deepPurple[900]!, // mainBackground (hsl(250, 50%, 20%))
    Colors.yellow[300]!, // mainAccent (hsl(45, 100%, 70%))
    Colors.purple[700]!, // secondaryBackground (hsl(240, 40%, 35%))
    Colors.cyan[100]!, // secondaryAccent (hsl(190, 100%, 85%))
    Colors.pink[600]!, // buttonBackground (hsl(330, 60%, 45%))
  ],
  "pinkGrey": [
    Colors.blueGrey[900]!, // mainBackground:
    Colors.blueGrey[50]!, // mainAccent:
    Colors.purple[600]!, // secondaryBackground:
    Colors.purple[200]!, // secondaryAccent:
    Color.fromRGBO(191, 159, 223, 1) // container
  ],
};
