import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/user_widget/friend/FriendListWidget.dart';

import 'friendTabMenu.dart';

class PendingRequestsWidget extends StatelessWidget {
  final FriendService friendService = FriendService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ThemeService ts = ThemeService.instance;
  PendingRequestsWidget({
    Key? key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: ts.mainBackground.value, // Set the background color to blue
                content: Container(
                  color: ts.mainBackground.value,
                  child: SizedBox(
                    width: 600,
                    height: 448,
                    child: FriendListDisplay(),
                  ),
                ),
              );
            },
          );
          },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.group,
              size: 48.0,
              color: Colors.white,
            ),
            if (loggedInUserService.friendRequests.value.isNotEmpty)
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: Color(0xFF3F51B5), // Blue circle
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${loggedInUserService.friendRequests.value.length}',
            style: const TextStyle(
              color: Colors.white, // White text
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),))
          ],
        ),
      );
    });
  }
}
