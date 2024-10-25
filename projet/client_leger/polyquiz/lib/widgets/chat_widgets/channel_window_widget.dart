import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';

// to be removed once connected to database
enum Page {
  select,
  join,
  create,
}

class ChannelWindowWidget extends StatefulWidget {
  final void Function(String) updateCurrentChannel;
  ChannelWindowWidget(this.updateCurrentChannel);

  State<ChannelWindowWidget> createState() => _ChannelWindowWidgetState();
}

class _ChannelWindowWidgetState extends State<ChannelWindowWidget> {
  Page currentPage = Page.select;

  @override
  Widget build(BuildContext context) {
    return buildCurrentPage();
  }

  Widget buildCurrentPage() {
    switch (currentPage) {
      case Page.join:
        return ChannelJoiningWidget(returnCallback: () {selectChannel(Page.select);});
      case Page.select:
      default:
        return ChannelSelectionWidget(widget.updateCurrentChannel, selectChannel);
    }
  }

  void selectChannel(Page value) {
    setState(() {
      currentPage = value;
    });
  }
}

class ChannelSelectionWidget extends StatefulWidget {
  final void Function(String) updateCurrentChannel;
  final void Function(Page) changePage;

  ChannelSelectionWidget(this.updateCurrentChannel, this.changePage);

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
            Expanded(child: ElevatedButton(onPressed: (){widget.changePage(Page.join);}, child: Text("Joindre un canal")))
          ]
        ),
        Expanded(child: Obx(() { return channelService.channels.isEmpty ? Text("empty") :
          ListView.builder(
            itemCount: channelService.permittedChannels.length,
              itemBuilder: (context, index) {
                return ChannelSelectionButton(buttonCallback: widget.updateCurrentChannel, name: channelService.permittedChannels[index].name, id: channelService.channels[index].id ?? "null");
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

class ChannelJoiningWidget extends StatefulWidget {
  final void Function() returnCallback;
  const ChannelJoiningWidget({required this.returnCallback, super.key});

  @override
  State<ChannelJoiningWidget> createState() => _ChannelJoiningWidgetState();
}

class _ChannelJoiningWidgetState extends State<ChannelJoiningWidget> {
  final channelService = Get.put(ChannelService());
  String _query = "";

  void searchChannels(String query) {
    setState(() {
      _query = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
            children: <Widget>[
              Expanded(child: Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: (){ widget.returnCallback(); }, icon: Icon(Icons.arrow_back)))),
              Expanded(child: Align(alignment: Alignment.center, child: Text("Joindre Canal")))
            ]
        ),
        // buildSearchBar(),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: channelService.joinableChannels.length,
                itemBuilder: (context, index) {
                  final channel = channelService.joinableChannels[index];
                  return buildChannelTile(channel.name, channel.id ?? '');
                }
            ),
          ),
        )
      ]
    );
  }

  Widget buildSearchBar() {
    return Placeholder();
  }

  Widget buildChannelTile(String name, String id) {
    return ListTile(
        title: TextButton(
          onPressed: () {},
          child: Container(child: Text(name)),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          )
      )
    );
  }
}
