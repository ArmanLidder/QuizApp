import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/main.dart';

import 'OtherUserPresentation.dart';

class SmartAvatar extends StatelessWidget {
  final double size;
  final String userId;

  SmartAvatar({required this.userId, this.size = 40.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => OtherUserPresentation(userId: userId),
        );
      },
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          children: [
            // Profile image using FutureBuilder for async data
            FutureBuilder<String?>(
              future: userService.getAvatar(userId), // Async call for avatar
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircleAvatar(
                    radius: size / 2,
                    backgroundColor: Colors.grey.shade200, // Placeholder color
                    child: CircularProgressIndicator(), // Loading indicator
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return CircleAvatar(
                    radius: size / 2,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.error), // Error icon
                  );
                } else {
                  return CircleAvatar(
                    radius: size / 2,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                }
              },
            ),
            // Level indicator using FutureBuilder
            Positioned(
              bottom: 0,
              right: 0,
              child: FutureBuilder<num>(
                future: userService.getLevel(userId).then((value) => value ?? 0),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(); // Show nothing if level isn't available yet
                  }
                  return Container(
                    width: size * 0.4, // Adjust size relative to profile image
                    height: size * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        snapshot.data!.toString(),
                        style: TextStyle(
                          fontSize: size * 0.2, // Adjust font size relative to profile image
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the OtherUserPresentation widget as a placeholder
