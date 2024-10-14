import 'package:flutter/material.dart';

class HistogramLegend extends StatelessWidget {
  const HistogramLegend({super.key});

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
            color: Color.fromRGBO(123, 229, 117, 1),
          )),
          TextSpan(
              text: 'Correct answers', style: TextStyle(color: Colors.black))
        ])),
        SizedBox(
          width: 30.0,
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child: Icon(
            Icons.square,
            color: Color.fromRGBO(246, 53, 53, 1),
          )),
          TextSpan(text: 'Wrong answers', style: TextStyle(color: Colors.black))
        ]))
      ],
    );
  }
}
