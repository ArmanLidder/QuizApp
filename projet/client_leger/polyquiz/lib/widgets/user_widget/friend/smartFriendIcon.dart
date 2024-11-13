import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

import '../../../services/friendService.dart';

class SmartFriendIcon extends StatefulWidget {
  final String targetUserId;
  final FriendService friendService = FriendService.instance;
  SmartFriendIcon({
    Key? key,
    required this.targetUserId,
  }) : super(key: key);

  @override
  _SmartFriendIconState createState() => _SmartFriendIconState();
}

class _SmartFriendIconState extends State<SmartFriendIcon> {
  String _status = 'loading';
  String? currentUserId = LoggedInUserService.instance.getUid();
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await widget.friendService.friendshipStatus(
      currentUserId!,
      widget.targetUserId,
    );
    setState(() {
      _status = status;
    });
  }

  Future<void> _handleIconPressed() async {
    if (_status == 'friends') {
      await widget.friendService.deleteFriendship(
        currentUserId!,
        widget.targetUserId,
      );
    } else if (_status == 'notFriends') {
      await widget.friendService.createFriendRequest(
        currentUserId!,
        widget.targetUserId,
      );
    } else if (_status == 'receivedPending') {
      await widget.friendService.acceptFriendRequest(
        currentUserId!,
        widget.targetUserId,
      );
    }
    await _checkStatus(); // Re-check status after the action
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (_status) {
      case 'friends':
        iconData = Icons.person_remove;
        iconColor = Colors.red;
        break;
      case 'sentPending':
        iconData = Icons.hourglass_empty;
        iconColor = Colors.grey;
        break;
      case 'receivedPending':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'notFriends':
        iconData = Icons.person_add;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.hourglass_empty;
        iconColor = Colors.grey;
    }

    return IconButton(
      icon: Icon(iconData, color: iconColor),
      onPressed: _status == 'sentPending'
          ? null // Does nothing if friend request is already sent
          : _handleIconPressed,
    );
  }
}
