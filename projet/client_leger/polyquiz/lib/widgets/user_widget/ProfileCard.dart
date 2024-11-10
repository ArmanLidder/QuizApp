import 'package:flutter/material.dart';
import 'package:polyquiz/widgets/user_widget/settings/SettingsPopup.dart';
import '../../services/imageStorageService.dart';
import '../../services/logged_in_user_service.dart';

class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();

  late String imageUrl;

  @override
  void initState() {
    super.initState();
    imageUrl = loggedInUserService.getUser()?.avatar ?? ''; // Initialize with the source image URL
  }

  Future<void> _imageChangeButton() async {
    await loggedInUserService.updateProfilePicture();
    setState(() {
      imageUrl = loggedInUserService.getUser()!.avatar; // Update the image URL
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? username = loggedInUserService.user?.username;
    final num? prestige = loggedInUserService.user?.prestige;
    final num? argent = loggedInUserService.user?.currency;

    return Stack(children: [
    Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),  // Round top-left corner
            topRight: Radius.circular(12.0), // Round top-right corner
          ),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ),
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
                            loggedInUserService.getUser()!.level.toString(),
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
                      child: GestureDetector(
                        onTap: _imageChangeButton,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  loggedInUserService.getUser()!.email,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ),
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
              ),
            ],
          ),
        ),
      ),
    ),
    Positioned(
      top: 16,  // Add padding from the top
      right: 16,
      child: GestureDetector(
      onTap: () {
        print("settigns button pressed"); //TODO: remove
          showDialog(
              context: context,
              builder: (BuildContext context) {
              return Dialog(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              ),
              child: SettingsPopup(), // Your custom settings popup widget
              );
              },
            );
          },
      child: Icon(
          Icons.settings, // Black line gear icon
          color: Colors.black,
          size: 32, // Adjust size as needed
        ),
      )
    ),
    ]);
  }
}
