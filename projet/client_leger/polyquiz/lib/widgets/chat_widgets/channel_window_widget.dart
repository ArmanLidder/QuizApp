import 'package:flutter/material.dart';

class ChannelWindowWidget extends StatefulWidget {
  State<ChannelWindowWidget> createState() => _ChannelWindowWidgetState();
}

class _ChannelWindowWidgetState extends State<ChannelWindowWidget> {
  @override
  Widget build(BuildContext context) {
    return ChannelSelectionWidget();
  }
}

class ChannelSelectionWidget extends StatefulWidget {
  State<ChannelSelectionWidget> createState() => _ChannelSelectionWidgetState();
}

class _ChannelSelectionWidgetState extends State<ChannelSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: ElevatedButton(onPressed: (){}, child: Text("Créer un canal"))),
            Expanded(child: ElevatedButton(onPressed: (){}, child: Text("Joindre un canal")))
          ]
        ),
        Expanded(child: Text("list of channels to be added"))
      ]
    );
  }
}