import 'package:flutter/material.dart';

class PlayersDataTableLegend extends StatelessWidget {
  const PlayersDataTableLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(246, 53, 53, 1),
          )),
          TextSpan(text: 'Inactif', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(255, 226, 108, 1),
          )),
          TextSpan(text: 'A intéragi', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(123, 229, 117, 1),
          )),
          TextSpan(text: 'A validé', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(31, 31, 31, 1),
          )),
          TextSpan(text: 'A quitté', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(221, 221, 221, 1),
          )),
          TextSpan(text: 'Fin de partie', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
      ],
    );
  }
}
