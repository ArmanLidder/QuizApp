import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/main.dart';
import 'package:polyquiz/services/theme_service.dart';

import '../../models/user.dart';
import 'OtherUserPresentation.dart';

class SmartAvatar extends StatelessWidget {
  final double size;
  final String userId;
  final bool interactible;
  final bool hasName;
  final bool applyTheme;

  SmartAvatar(
      {required this.userId,
      this.size = 40.0,
      this.interactible = true,
      this.hasName = false,
      this.applyTheme = true});

  ThemeService _themeService = ThemeService.instance;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (interactible) {
          showDialog(
            context: context,
            builder: (context) => OtherUserPresentation(userId: userId),
          );
        }
      },
      child: Container(
        height: size * 1.3,
        width: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            FutureBuilder<User?>(
              future: userService.getUserById(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Positioned(
                      bottom: 0.3 * size,
                      child: CircleAvatar(
                        radius: size / 2,
                        backgroundColor: Colors.grey.shade200,
                        child: CircularProgressIndicator(),
                      ));
                } else if (snapshot.hasError || snapshot.data == null) {
                  return Positioned(
                      bottom: 0.3 * size,
                      child: CircleAvatar(
                        radius: size / 2,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.error),
                      ));
                } else {
                  return Stack(
                    children: [
                      Positioned(
                          bottom: 0.3 * size,
                          child: CircleAvatar(
                            radius: size / 2,
                            backgroundImage:
                                NetworkImage(snapshot.data!.avatar),
                          )),
                      Positioned(
                        bottom: 0.3 * size,
                        right: 0,
                        child: Container(
                          width: size * 0.4,
                          height: size * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              snapshot.data!.level.toString(),
                              style: TextStyle(
                                fontSize: size * 0.2,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: hasName
                            ? Center(
                                child: Text(
                                  snapshot.data!.username,
                                  style: TextStyle(
                                    fontSize: size *
                                        0.2, // Adjust based on desired scaling
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                    color: applyTheme
                                        ? _themeService.mainAccent.value
                                        : Colors.black, // Set the text color
                                  ),
                                  maxLines:
                                      1, // Ensure the text only takes one line
                                  overflow: TextOverflow
                                      .ellipsis, // Truncate with ellipsis if it overflows
                                ),
                              )
                            : SizedBox
                                .shrink(), // Use SizedBox.shrink() for an empty widget when hasName is false
                      ),
                    ],
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
