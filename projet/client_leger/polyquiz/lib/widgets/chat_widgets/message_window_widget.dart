import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';

class MessageWindowWidget extends StatefulWidget {
  final void Function() returnCallback;
  final String channelId;
  const MessageWindowWidget({required this.channelId, required this.returnCallback, super.key});

  @override
  State<MessageWindowWidget> createState() => _MessageWindowWidgetState();
}

class _MessageWindowWidgetState extends State<MessageWindowWidget> {
  final channelService = Get.put(ChannelService());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: (){ widget.returnCallback(); }, icon: Icon(Icons.arrow_back)))),
            Expanded(child: Align(alignment: Alignment.center, child: Text(getChannel().name)))
          ]
        ),
        Expanded(child: Obx(() {
          return MessageListWidget(messages: getChannel().messages.isEmpty ? [] : getChannel().messages);
        }))
      ]
    );
  }

  Canal getChannel() {
    bool channelById(Canal channel) => channel.id == widget.channelId;
    return channelService.channels.toList().firstWhere(channelById);
  }
}

class MessageListWidget extends StatelessWidget {
  final List<Message> messages;
  const MessageListWidget({required this.messages, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return MessageTile(content: messages[index].message, userId: messages[index].userUid);
        }
    );
  }
}

class MessageTile extends StatelessWidget {
  final imageUrl = "https://i.pinimg.com/originals/87/a2/d6/87a2d6017b9a7cc38274cef92a45cee3.jpg"; // TODO: Remove and add images
  final username = "Elsa";

  final String content;
  final String userId;
  const MessageTile({required this.content, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return isUserSender() ? buildSentMessage() : buildReceivedMessage();
  }

  Widget buildSentMessage() {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(content)
        ),
      ),
      trailing: buildUserInfo(),
    );
  }

  Widget buildReceivedMessage() {
    return ListTile(
      title: Align(
        alignment: Alignment.centerLeft,
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(content)
        ),
      ),
      leading: buildUserInfo(),
    );
  }

  Widget buildUserInfo() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
        Flexible(child: Text(username))
      ],
    );
  }

  bool isUserSender() {
    return false;
  }
}
