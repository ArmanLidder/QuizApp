import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';

class MessageWindowWidget extends StatefulWidget {
  final void Function() returnCallback;
  final String channelId;
  const MessageWindowWidget({required this.channelId, required this.returnCallback, super.key});

  @override
  State<MessageWindowWidget> createState() => _MessageWindowWidgetState();
}

class _MessageWindowWidgetState extends State<MessageWindowWidget> {
  final channelService = ChannelService.instance;
  final _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

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
          return MessageListWidget(messages: getChannel().messages.isEmpty ? [] : getChannel().messages, scrollController: _scrollController,);
        })),
        buildInputBox(),
      ]
    );
  }

  Canal getChannel() {
    bool channelById(Canal channel) => channel.id == widget.channelId;
    return channelService.channels.toList().firstWhere(channelById);
  }

  Widget buildInputBox() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: "input a message...",
              border: InputBorder.none,
            ),
            onSubmitted: (value) => sendMessage(),
          ),
        ),
        IconButton(onPressed: sendMessage, icon: Icon(Icons.send, color: Colors.blue))
      ],
    );
  }

  Future<void> sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) {
      return Future.value();
    }
    await channelService.addMessage(widget.channelId, content);
    _messageController.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(microseconds: 300),
        curve: Curves.easeInOut
    );
  }
}

class MessageListWidget extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;
  const MessageListWidget({required this.messages, required this.scrollController, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
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
  final userService = UserService.instance;
  final loggedInService = LoggedInUserService.instance;

  final String content;
  final String userId;
  MessageTile({required this.content, required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return isUserSender() ? buildSentMessage() : buildReceivedMessage();
  }

  // TODO: REMOVE THESE METHODS AND REPLACE W/ BETTER ONE
  Future<String> getUsername() async {
    final user = await userService.getUserById(userId);
    if (user == null) return username;
    return user.username;
  }

  Future<String> getImageUrl() async {
    final user = await userService.getUserById(userId);
    if (user == null) return imageUrl;
    return user.avatar;
  }

  Widget buildSentMessage() {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
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
              color: Colors.grey[300],
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
          child: FutureBuilder(
            future: getImageUrl(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) => CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data ?? imageUrl),
            ),
          ),
        ),
        Flexible(child: FutureBuilder(future: getUsername(), builder: (BuildContext context, AsyncSnapshot<String> snapshot) => Text(snapshot.data ?? username)))
      ],
    );
  }

  bool isUserSender() {
    return userId == loggedInService.user?.uid; // TODO: Fix this so it isn't hardcoded
  }
}
