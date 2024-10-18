import 'package:flutter/material.dart';

// to be removed once connected to database
const List<String> fakeData = [
  "general",
  "ungeneral",
  "kanal",
  "kanal2",
];

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
        Expanded(child: ListView.builder(
          itemCount: fakeData.length,
            itemBuilder: (context, index) {
              return ChannelSelectionButton(buttonCallback: (){}, name: fakeData[index], id: fakeData[index]);
            }
        ))
      ]
    );
  }
}

class ChannelSelectionButton extends StatelessWidget {
  final void Function() buttonCallback;
  final String name;
  final String id;

  const ChannelSelectionButton({
    super.key,
    required this.buttonCallback,
    required this.name,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextButton(
          onPressed: (){},
          child: Container(child: Text(name)),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          )
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(onPressed: (){}, icon: Icon(Icons.logout)),
            IconButton(onPressed: (){}, icon: Icon(Icons.delete))
          ]
        ),
      )
    );
  }
}