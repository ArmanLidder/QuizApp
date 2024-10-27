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
      case Page.create:
        return ChannelCreationWidget(returnCallback: () {selectChannel(Page.create);});
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
            Expanded(child: ElevatedButton(onPressed: (){widget.changePage(Page.create);}, child: Text("Créer un canal"))),
            Expanded(child: ElevatedButton(onPressed: (){widget.changePage(Page.join);}, child: Text("Joindre un canal")))
          ]
        ),
        Expanded(child: Obx(() { return channelService.channels.isEmpty ? Text("empty") :
          ListView.builder(
            itemCount: channelService.permittedChannels.length,
              itemBuilder: (context, index) {
                final channel = channelService.permittedChannels[index];
                return ChannelSelectionButton(
                    buttonCallback: widget.updateCurrentChannel,
                    leaveChannelCallback: () {channelService.leaveChannel(channel.id!);},
                    deleteChannelCallback: () {channelService.deleteChannel(channel.id!);},
                    name: channel.name,
                    id: channel.id ?? "null"
                );
              }
        );}))
      ]
    );
  }
}

class ChannelSelectionButton extends StatelessWidget {
  final void Function(String) buttonCallback;
  final void Function() leaveChannelCallback;
  final void Function() deleteChannelCallback;
  final String name;
  final String id;

  const ChannelSelectionButton({
    super.key,
    required this.buttonCallback,
    required this.leaveChannelCallback,
    required this.deleteChannelCallback,
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
      trailing: name == 'general' ? null : SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(onPressed: (){leaveChannelCallback();}, icon: Icon(Icons.logout)),
            IconButton(onPressed: (){deleteChannelPopup(context);}, icon: Icon(Icons.delete))
          ]
        ),
      )
    );
  }

  void deleteChannelPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text("Attention !!!"),
          content: Text("Cette action est irreversible. Le canal ${name} sera effacé à jamais."),
          actions: <Widget>[
            TextButton(onPressed: () { return Navigator.pop(context); }, child: Text("Annuler")),
            TextButton(onPressed: () {
              deleteChannelCallback();
              Navigator.pop(context);
            }, child: Text("Supprimer"))
          ],
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
          onPressed: () {channelService.joinChannel(id);},
          child: Container(child: Text(name)),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          )
      )
    );
  }
}

class ChannelCreationWidget extends StatefulWidget {
  final returnCallback;
  const ChannelCreationWidget({required this.returnCallback, super.key});

  @override
  State<ChannelCreationWidget> createState() => _ChannelCreationWidgetState();
}

class _ChannelCreationWidgetState extends State<ChannelCreationWidget> {
  final inputController = TextEditingController();
  final channelService = Get.put(ChannelService());
  String _currentName = "";

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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: inputController,
              onChanged: (content) {setState(() {
                _currentName = inputController.text.trim();
              });},
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Saisir un nom de canal...',
              ),
            )
          ),
          Column(children: channelErrorMessage(_currentName)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextButton(
                onPressed: isValidChannelName(_currentName) ? (){} : null,
                child: Text("Créer"),
                style: TextButton.styleFrom(
                  backgroundColor: isValidChannelName(_currentName) ? Colors.blue : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
                ),
            ),
          )
        ]
    );
  }

  bool isValidChannelName(String name) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(name) && name.length <= 20 && name.length > 0;
  }

  List<Widget> channelErrorMessage(String name) {
    List<Widget> errors = [];
    final errorStyle = TextStyle(color: Colors.red);
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumeric.hasMatch(name) && name.isNotEmpty) errors.add(Text(
      "Le nom du canal doit seulement contenir des caractères alphanumériques.",
      style: errorStyle
    ));
    if (name.length > 20) errors.add(Text(
      "Le nom du canal doit contenir 20 caractères maximum.",
      style: errorStyle,
    ));
    if (name.isEmpty) errors.add(Text(
      "Le nom de canal est requis.",
      style: errorStyle,
    ));

    return errors;
  }
}
