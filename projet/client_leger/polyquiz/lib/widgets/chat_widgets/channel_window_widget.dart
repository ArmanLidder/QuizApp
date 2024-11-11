import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

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
        return ChannelJoiningWidget(returnCallback: () {
          selectChannel(Page.select);
        });
      case Page.create:
        return ChannelCreationWidget(returnCallback: () {
          selectChannel(Page.select);
        });
      case Page.select:
      default:
        return ChannelSelectionWidget(
            widget.updateCurrentChannel, selectChannel);
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
  final channelService = ChannelService.instance;

  @override
  void initState() {
    super.initState();
  }

  ButtonStyle get channelModificationStyle {
    return TextButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
            child: TextButton(
                onPressed: () {
                  widget.changePage(Page.create);
                },
                child: Text("Ajouter un Canal"),
              style: channelModificationStyle,
            )
        ),
        SizedBox(width: 10,),
        Expanded(
            child: TextButton(
                onPressed: () {
                  widget.changePage(Page.join);
                },
                child: Text("Joindre un Canal"),
                style: channelModificationStyle,
            )
        )
      ]),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "Mes canaux",
                style: TextStyle(
                  fontSize: 20,
                ),
            )
        ),
      ),
      Expanded(child: Obx(() {
        return channelService.channels.isEmpty
            ? Text("empty")
            : ListView.builder(
                itemCount: channelService.permittedChannels.length,
                itemBuilder: (context, index) {
                  final channel = channelService.permittedChannels[index];
                  return ChannelSelectionButton(
                      buttonCallback: widget.updateCurrentChannel,
                      leaveChannelCallback: () {
                        channelService.leaveChannel(channel.id!);
                      },
                      deleteChannelCallback: () {
                        channelService.deleteChannel(channel.id!);
                      },
                      name: channel.name,
                      id: channel.id ?? "null");
                });
      }))
    ]);
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
    bool shouldHaveLeaveAndDeleteButton = name != 'general' && !name.toLowerCase().contains("room");

    Widget leaveAndDeleteButtons =  SizedBox(
      width: 100,
      child: Row(children: <Widget>[
        IconButton(
            onPressed: () {
              leaveChannelCallback();
            },
            icon: Icon(Icons.logout, size: 20)),
        IconButton(
            onPressed: () {
              deleteChannelPopup(context);
            },
            icon: Icon(Icons.delete, color: Colors.red, size: 20)
        )
      ]),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: TextButton(
          onPressed: () => buttonCallback(id),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(name),
              ),
              if (shouldHaveLeaveAndDeleteButton) leaveAndDeleteButtons,
            ],
          )
      )
    );
    // return Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: ListTile(
    //       tileColor: Colors.grey[200],
    //       title: TextButton(
    //           onPressed: () => buttonCallback(id),
    //           child: Container(child: Text(name)),
    //           style: TextButton.styleFrom(
    //               alignment: Alignment.centerLeft,
    //
    //               shape:
    //                   RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
    //       trailing: name == 'general'
    //           ? null
    //           : SizedBox(
    //               width: 100,
    //               child: Row(children: <Widget>[
    //                 IconButton(
    //                     onPressed: () {
    //                       leaveChannelCallback();
    //                     },
    //                     icon: Icon(Icons.logout)),
    //                 IconButton(
    //                     onPressed: () {
    //                       deleteChannelPopup(context);
    //                     },
    //                     icon: Icon(Icons.delete)
    //                 )
    //               ]),
    //             )
    //   ),
    // );
  }

  void deleteChannelPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Attention !!!"),
              content: Text(
                  "Cette action est irreversible. Le canal ${name} sera effacé à jamais."),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      return Navigator.pop(context);
                    },
                    child: Text("Annuler")),
                TextButton(
                    onPressed: () {
                      deleteChannelCallback();
                      Navigator.pop(context);
                    },
                    child: Text("Supprimer"))
              ],
            ));
  }
}

class ChannelJoiningWidget extends StatefulWidget {
  final void Function() returnCallback;
  const ChannelJoiningWidget({required this.returnCallback, super.key});

  @override
  State<ChannelJoiningWidget> createState() => _ChannelJoiningWidgetState();
}

class _ChannelJoiningWidgetState extends State<ChannelJoiningWidget> {
  final channelService = ChannelService.instance;
  String _query = "";

  String get query => _query;

  void set query(String value) => setState(() {
    _query = value;
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      widget.returnCallback();
                    },
                    icon: Icon(Icons.arrow_back)))),
        Expanded(
            child: Align(
                alignment: Alignment.center, child: Text("Joindre Canal")))
      ]),
      buildSearchBar(),
      Expanded(
        child: Obx(
          () {
            final filteredChannels = channelService.joinableChannels.where((channel) =>
              channel.name.toLowerCase().contains(query.toLowerCase())
            ).toList();
            return ListView.builder(
              itemCount: filteredChannels.length,
              itemBuilder: (context, index) {
                final channel = filteredChannels[index];
                return buildChannelTile(channel.name, channel.id ?? '');
              });
            },
        ),
      )
    ]);
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) {
          query = value.trim(); // Update query and refresh the list
        },
        decoration: InputDecoration(
          hintText: "Chercher un canal...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildChannelTile(String name, String id) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextButton(
              onPressed: () {
                channelService.joinChannel(id);
                widget.returnCallback();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(name)
              ),
              // style: TextButton.styleFrom(
              //     alignment: Alignment.centerLeft,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
              // )
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 0),
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
              )
      ),
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
  final channelService = ChannelService.instance;
  final loggedInService = LoggedInUserService.instance;
  String _currentName = "";

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      widget.returnCallback();
                    },
                    icon: Icon(Icons.arrow_back)))),
        Expanded(
            child: Align(
                alignment: Alignment.center, child: Text("Joindre Canal")))
      ]),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: inputController,
            onChanged: (content) {
              setState(() {
                _currentName = inputController.text.trim();
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Saisir un nom de canal...',
            ),
          )),
      Column(children: channelErrorMessage(_currentName)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextButton(
          onPressed: isValidChannelName(_currentName)
              ? () {
                  createChannel(context);
                }
              : null,
          child: Text("Créer"),
          style: TextButton.styleFrom(
              backgroundColor: isValidChannelName(_currentName)
                  ? Colors.blue
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4))),
        ),
      )
    ]);
  }

  bool isValidChannelName(String name) {
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(name) && name.length <= 20 && name.length > 0;
  }

  List<Widget> channelErrorMessage(String name) {
    List<Widget> errors = [];
    final errorStyle = TextStyle(color: Colors.red);
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    if (!alphanumeric.hasMatch(name) && name.isNotEmpty)
      errors.add(Text(
          "Le nom du canal doit seulement contenir des caractères alphanumériques.",
          style: errorStyle));
    if (name.length > 20)
      errors.add(Text(
        "Le nom du canal doit contenir 20 caractères maximum.",
        style: errorStyle,
      ));
    if (name.isEmpty)
      errors.add(Text(
        "Le nom de canal est requis.",
        style: errorStyle,
      ));

    return errors;
  }

  void sameChannelNamePopup(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text("Erreur"),
              content: Text(msg),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      return Navigator.pop(context);
                    },
                    child: Text("OK")),
              ],
            ));
  }

  // Future<void> createChannel(BuildContext context) async {
  //   bool isCreated = await channelService.createChannel(_currentName, [loggedInService.user?.uid ?? ""], false);
  //   if (isCreated) {
  //     inputController.clear();
  //     widget.returnCallback();
  //     return;
  //   }
  //   sameChannelNamePopup(context, "Un canal ne peut pas avoir le même nom");
  //   inputController.clear();
  // }

  Future<void> createChannel(BuildContext context) async {
    final canalName = _currentName;
    final userId = loggedInService.user?.uid ?? "";

    if (canalName.toLowerCase().contains("room")) {
      // Show feedback if the name contains "room"
      sameChannelNamePopup(context,
          "Le nom de canal ne peut pas contenir: room. Veuillez choisir un autre nom.");
      return;
    }

    if (canalName.isNotEmpty) {
      try {
        final isCreated =
            await channelService.createChannel(canalName, [userId], false);

        if (isCreated) {
          // Channel created successfully
          inputController.clear();
          widget.returnCallback();
        } else {
          // Handle duplicate name case
          sameChannelNamePopup(context,
              "Le nom $canalName est déjà utilisé. Veuillez choisir un autre nom.");
        }
      } catch (error) {
        // Handle any other errors
        sameChannelNamePopup(context,
            "Erreur lors de la création du canal: ${error.toString()}");
      }
    }
  }
}
