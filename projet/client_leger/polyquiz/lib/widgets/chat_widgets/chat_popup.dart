import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/notification_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_widget.dart';

class ChatPopup extends StatefulWidget {
  const ChatPopup({super.key});

  @override
  State<ChatPopup> createState() => _ChatPopupState();
}

class _ChatPopupState extends State<ChatPopup> {
  bool _isChatOpen = false;
  NotificationService notificationService = NotificationService.instance;

  bool get isChatOpen => _isChatOpen;
  void set isChatOpen(bool value) {
    setState(() {
      _isChatOpen = value;
    });
    notificationService.isChatOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomRight,
          child: buildHoveringButton(context),
        ),
      ],
    );
  }

  Widget buildHoveringButton(BuildContext context) {
    ThemeService themeService = ThemeService.instance;

    return Obx(() => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: themeService.secondaryBackground.value,
                shape: BoxShape.circle,
              ),
              padding:
                  EdgeInsets.all(8), // Adjusts the padding to control icon size
              child: IconButton(
                onPressed: () => openChat(context),
                icon: Icon(Icons.message_rounded,
                    color: themeService.secondaryAccent.value),
              ),
            ),
            if (notificationService.hasUnreadChannels.value)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ));
  }

  void openChat(BuildContext context) {
    isChatOpen = true;
    if (ChannelService.instance.permittedChannels.length == 1)
      notificationService
          .readChannel(ChannelService.instance.permittedChannels.first.id!);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              clipBehavior: Clip.hardEdge,
              // content: Expanded(child: ChatWidget()),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Container(
                width: 700,
                height: 700,
                child: ChatWidget(),
              ));
        }).then((val) {
      isChatOpen = false;
      notificationService.clearCurrentChannel();
    });
  }
}
