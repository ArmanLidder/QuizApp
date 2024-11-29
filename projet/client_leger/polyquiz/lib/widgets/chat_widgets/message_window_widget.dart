import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/widgets/user_widget/smartAvatar.dart';

class MessageWindowWidget extends StatefulWidget {
  final void Function() returnCallback;
  final String channelId;
  const MessageWindowWidget(
      {required this.channelId, required this.returnCallback, super.key});

  @override
  State<MessageWindowWidget> createState() => _MessageWindowWidgetState();
}

class _MessageWindowWidgetState extends State<MessageWindowWidget> {
  final channelService = ChannelService.instance;
  final _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  String defaultName = 'null';
  List<Message> defaultMessages = [];
  ThemeService _themeService = ThemeService.instance;
  Map get text => TranslationService.instance.text;
  Map get chatText => text['CHAT_COMPONENT'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<Message> messages = getChannel()?.messages ?? defaultMessages;
      String channelName = getChannel()?.name ?? defaultName;
      return Column(children: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      onPressed: () {
                        widget.returnCallback();
                      },
                      icon: Icon(Icons.arrow_back),
                      color: _themeService.secondaryBackground.value))),
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Text(channelName,
                      style: TextStyle(color: _themeService.mainAccent.value))))
        ]),
        Expanded(
            child: MessageListWidget(
          messages: messages.isEmpty ? [] : messages,
          scrollController: _scrollController,
        )),
        if (getChannel() == null) getDeletedChannelText(),
        buildInputBox(),
      ]);
    });
  }

  Canal? getChannel() {
    bool channelById(Canal channel) => channel.id == widget.channelId;
    try {
      Canal channel = channelService.channels.toList().firstWhere(channelById);
      defaultName = channel.name;
      return channel;
    } on StateError catch (e) {
      return null;
    }
  }

  Widget getDeletedChannelText() {
    return Text(
      chatText['CHANNEL_DELETED'],
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }

  Widget buildInputBox() {
    bool isChannelAvailable = getChannel() != null;
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            style: TextStyle(color: _themeService.mainAccent.value),
            controller: _messageController,
            decoration: InputDecoration(
              hintText: chatText['ENTER_MESSAGE'],
              hintStyle: TextStyle(color: _themeService.mainAccent.value),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey, width: 1)),
            ),
            enabled: isChannelAvailable,
            onSubmitted: isChannelAvailable ? (value) => sendMessage() : null,
          ),
        ),
        IconButton(
            onPressed: isChannelAvailable ? sendMessage : null,
            icon: Icon(Icons.send,
                color: isChannelAvailable
                    ? _themeService.secondaryBackground.value
                    : Colors.grey))
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
    await Future.delayed(const Duration(milliseconds: 250));
    scrollToBottom();
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(microseconds: 300), curve: Curves.easeInOut);
  }
}

class MessageListWidget extends StatelessWidget {
  final List<Message> messages;
  final ScrollController scrollController;
  const MessageListWidget(
      {required this.messages, required this.scrollController, super.key});
  Map get text => TranslationService.instance.text;
  Map get chatText => text['CHAT_COMPONENT'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return MessageTile(
            message: messages[index],
          );
        });
  }
}

class MessageTile extends StatelessWidget {
  final imageUrl =
      "https://i.pinimg.com/originals/87/a2/d6/87a2d6017b9a7cc38274cef92a45cee3.jpg"; // TODO: Remove and add images
  final username = "Elsa";
  final userService = UserService.instance;
  final loggedInService = LoggedInUserService.instance;

  final Message message;
  String get content => message.message;
  String get userId => message.userUid;
  Timestamp get timestamp => message.createdAt;
  MessageTile({required this.message, super.key});
  final ThemeService _themeService = ThemeService.instance;

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

  String formatTimestamp() {
    DateTime dateTime = timestamp.toDate();
    return DateFormat("MM/dd/yy, hh:mm a").format(dateTime);
  }

  Widget getTimestampText(bool userMessage) {
    return Text(
      formatTimestamp(),
      style: TextStyle(
          fontSize: 10,
          color: userMessage
              ? _themeService.secondaryAccent.value
              : _themeService.mainAccent.value),
    );
  }

  Widget getTextContent(bool userMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(content,
            style: TextStyle(
                color: userMessage
                    ? _themeService.secondaryAccent.value
                    : _themeService.mainAccent.value)),
        SizedBox(height: 5),
        getTimestampText(userMessage),
      ],
    );
  }

  Widget buildSentMessage() {
    return ListTile(
      title: Align(
        alignment: Alignment.centerRight,
        child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: _themeService.secondaryBackground.value,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: getTextContent(true)),
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
              color: _themeService.container.value,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: getTextContent(false)),
      ),
      leading: buildUserInfo(),
    );
  }

  Widget buildUserInfo() {
    return SmartAvatar(
      userId: userId,
      size: 42,
      hasName: true,
      interactible: true,
    );
    //
    // Column(
    //   children: <Widget>[
    //     Expanded(
    //       flex: 3,
    //       child: FutureBuilder(
    //         future: getImageUrl(),
    //         builder: (BuildContext context, AsyncSnapshot<String> snapshot) => CircleAvatar(
    //           backgroundImage: NetworkImage(snapshot.data ?? imageUrl),
    //         ),
    //       ),
    //     ),
    //     Flexible(child: FutureBuilder(
    //         future: getUsername(),
    //         builder: (BuildContext context, AsyncSnapshot<String> snapshot)
    //           => Container(
    //             width: 70,
    //             child: Text(
    //               snapshot.data ?? username,
    //               textAlign: TextAlign.center,
    //               overflow: TextOverflow.ellipsis,
    //               maxLines: 1,),
    //           )
    //     ))
    //   ],
    // );
  }

  bool isUserSender() {
    return userId ==
        loggedInService.user?.uid; // TODO: Fix this so it isn't hardcoded
  }
}
