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
            IconButton(onPressed: (){ widget.returnCallback(); }, icon: Icon(Icons.arrow_back)),
            Text("Channel Name") // TODO: Change once I can access channel name
          ]
        ),
        Expanded(child: Obx(() {
          return MessageListWidget(messages: getMessagesFromChannel().isEmpty ? [] : getMessagesFromChannel());
        }))
      ]
    );
  }

  List<Message> getMessagesFromChannel() {
    bool channelById(Canal channel) => channel.id == widget.channelId;
    return channelService.channels.toList().firstWhere(channelById).messages;
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
  final String content;
  final String userId;
  const MessageTile({required this.content, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(content);
  }
}
