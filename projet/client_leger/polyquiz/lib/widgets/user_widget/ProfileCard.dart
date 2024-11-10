import 'package:flutter/material.dart';

import '../../services/imageStorageService.dart';
import '../../services/logged_in_user_service.dart';

class ProfileCard extends StatelessWidget {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();


  @override
  Widget build(BuildContext context) {
    final String? username = this.loggedInUserService.user?.username;
    final num? prestige = this.loggedInUserService.user?.prestige;
    final num? argent = this.loggedInUserService.user?.currency;

    return Align(
      alignment: Alignment.topCenter,
      child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              //borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2), // White outline
                      ),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: NetworkImage(this.loggedInUserService.user!.avatar),
                      ),),
                    Positioned(
                      bottom: 106,
                      right: 106,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            this.loggedInUserService.getUser()!.level.toString(),
                            style: TextStyle(
                              fontSize: 10,
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
                      child:GestureDetector(
                        onTap: () {
                          // Add your onPressed functionality here
                          print("Edit icon tapped"); // Placeholder action
                        },
                        child: Container(
                          width: 40, // Adjust the size as needed
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit, // Pen icon
                              color: Colors.blue,
                              size: 20, // Adjust the icon size as needed
                            ),
                          ),
                        ),
                    ),
                      )
                  ],
                )
                ),
                Center(
                  child: Text(
                    'Profile of $username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Center(
                    child: Text(
                  this.loggedInUserService.getUser()!.email,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                )),
                SizedBox(height: 16.0),
                Center(
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      Chip(
                        label: Text(
                          "prestige: $prestige",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      Chip(
                        label: Text(
                          "argent: $argent",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
          )),
    );
  }
}
