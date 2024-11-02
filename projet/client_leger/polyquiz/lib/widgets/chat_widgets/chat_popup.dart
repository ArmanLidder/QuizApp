import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/notification_service.dart';
import 'package:polyquiz/widgets/chat_widgets/chat_widget.dart';

class ChatPopup extends StatefulWidget {
  const ChatPopup({super.key});

  @override
  State<ChatPopup> createState() => _ChatPopupState();
}

class _ChatPopupState extends State<ChatPopup> {
  bool _isChatOpen = false;
  NotificationService notificationService = NotificationService.instance;

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
    return Obx(() => IconButton(
        onPressed: () => openChat(context),
        icon: Icon(Icons.message_rounded),
        color: notificationService.hasUnreadChannels.value ? Colors.red : Colors.green,
    ));
  }

  void openChat(BuildContext context) {
    setState(() {
      _isChatOpen = true;
    });

    showDialog(context: context, builder: (BuildContext context) {
      return Dialog(
        clipBehavior: Clip.hardEdge,
        // content: Expanded(child: ChatWidget()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Container(
          width: 700,
          height: 700,
          child: ChatWidget(),
        )
      );
    }).then((val) {
      setState(() {
        _isChatOpen = false;
      });
    });
  }
}
