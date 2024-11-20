import 'package:flutter/material.dart';
import 'package:polyquiz/services/friendService.dart';
import '../../../services/logged_in_user_service.dart';

class AcceptOrRefuse extends StatelessWidget {
  final String targetUserId;
  final FriendService friendService = FriendService.instance;
  final String? currentUserId = LoggedInUserService.instance.getUid();

  AcceptOrRefuse({
    Key? key,
    required this.targetUserId,
  }) : super(key: key);

  Future<void> _acceptRequest() async {
    await friendService.acceptFriendRequest(currentUserId!, targetUserId);
  }

  Future<void> _refuseRequest() async {
    await friendService.refuseFriendRequest(currentUserId!, targetUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Accept button - green circle with check
        GestureDetector(
          onTap: _acceptRequest,
          child: CircleAvatar(
            backgroundColor: Colors.green,
            radius: 25,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        SizedBox(width: 20),
        // Refuse button - red circle with cross
        GestureDetector(
          onTap: _refuseRequest,
          child: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 25,
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}
