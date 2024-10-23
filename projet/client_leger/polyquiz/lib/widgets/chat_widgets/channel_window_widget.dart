import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';

// to be removed once connected to database

class ChannelWindowWidget extends StatefulWidget {
  final void Function(String) updateCurrentChannel;
  ChannelWindowWidget(this.updateCurrentChannel);

  State<ChannelWindowWidget> createState() => _ChannelWindowWidgetState();
}

class _ChannelWindowWidgetState extends State<ChannelWindowWidget> {
  @override
  Widget build(BuildContext context) {
    return ChannelSelectionWidget(widget.updateCurrentChannel);
  }
}

class ChannelSelectionWidget extends StatefulWidget {
  final void Function(String) updateCurrentChannel;

  ChannelSelectionWidget(this.updateCurrentChannel);

  State<ChannelSelectionWidget> createState() => _ChannelSelectionWidgetState();
}

class _ChannelSelectionWidgetState extends State<ChannelSelectionWidget> {
  final channelService = Get.put(ChannelService());

  @override
  void initState() {
    super.initState();
  }

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
        Expanded(child: Obx(() { return channelService.channels.isEmpty ? Text("empty") :
          ListView.builder(
            itemCount: channelService.channels.length,
              itemBuilder: (context, index) {
                return ChannelSelectionButton(buttonCallback: widget.updateCurrentChannel, name: channelService.channels[index].name, id: channelService.channels[index].id ?? "null");
              }
        );}))
      ]
    );
  }
}

class ChannelSelectionButton extends StatelessWidget {
  final void Function(String) buttonCallback;
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
          onPressed: () => buttonCallback(id),
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