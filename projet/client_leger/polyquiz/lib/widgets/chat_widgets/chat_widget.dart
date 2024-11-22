import 'package:flutter/material.dart';
import 'package:polyquiz/services/notification_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/chat_widgets/channel_window_widget.dart';
import 'package:polyquiz/widgets/chat_widgets/message_window_widget.dart';

enum Page { Channel, Message }

class ChatWidget extends StatefulWidget {
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  Page page = Page.Channel;
  String currentChannelId = "Clavardage";
  NotificationService notificationService = NotificationService.instance;
  ThemeService themeService = ThemeService.instance;

  Map get text => TranslationService.instance.text;
  Map get chatText => text['CHAT_COMPONENT'];

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: Container(
            color: themeService.secondaryBackground.value,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Icon(
                  Icons.textsms,
                  size: 40,
                  color: themeService.secondaryAccent.value,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(chatText['CHAT'],
                    style: TextStyle(
                        fontSize: 40,
                        color: themeService.secondaryAccent.value)),
              ],
            )),
      ),
      Expanded(
          flex: 9,
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: buildCurrentPage(),
          ))
    ]);
  }

  Widget buildCurrentPage() {
    switch (page) {
      case Page.Message:
        return MessageWindowWidget(
            channelId: currentChannelId,
            returnCallback: () {
              setState(() {
                page = Page.Channel;
              });
            });
      case Page.Channel:
      default:
        return ChannelWindowWidget(selectChannel);
    }
  }

  void selectChannel(String id) {
    setState(() {
      currentChannelId = id;
      page = Page.Message;
    });
    notificationService.readChannel(id);
  }
}
