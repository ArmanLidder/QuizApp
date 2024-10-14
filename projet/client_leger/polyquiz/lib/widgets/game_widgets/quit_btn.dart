import 'package:flutter/material.dart';

class QuitBtn extends StatelessWidget {
  const QuitBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Quit',
        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
      ),
      style: TextButton.styleFrom(
          textStyle: TextStyle(fontWeight: FontWeight.normal),
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
    );
  }
}
