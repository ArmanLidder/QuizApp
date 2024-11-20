import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

import 'friendTabMenu.dart';

class PendingRequestsWidget extends StatelessWidget {
  final FriendService friendService = FriendService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

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
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: FriendDisplayBox(),
                ),
              );
            },
          );
          },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 48.0,
              color: Colors.black,
            ),
            if (loggedInUserService.friendRequests.value.isNotEmpty)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20.0,
                  height: 20.0,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${loggedInUserService.friendRequests.value.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
