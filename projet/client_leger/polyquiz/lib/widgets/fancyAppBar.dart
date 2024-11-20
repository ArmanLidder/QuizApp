import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/user_widget/settings/SettingsPopup.dart';

class FancyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final BuildContext context;

  FancyAppBar({required this.context});

  @override
  _FancyAppBarState createState() => _FancyAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(60.0); // Adjust the height if needed
}

class _FancyAppBarState extends State<FancyAppBar> {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  late String imageUrl; // Use late keyword to initialize later
  final ThemeService themeService = ThemeService.instance;
  @override
  void initState() {
    super.initState();
    imageUrl = loggedInUserService.observableAvatar.value; // Initialize with the source image URL
  }


  @override
  Widget build(BuildContext barContext) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: AppBar(
        title: Center(
          child: Text(
            "PolyQuiz",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () {
            Navigator.pushReplacementNamed(widget.context, '/home');   }),
        actions: [
          GestureDetector(
            onTap: () {
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
              Icons.settings,
              color: themeService.mainAccent.value,
              size: 32,
            ),
          ),
          SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<int>(
              onSelected: (value) {},
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.person),
                      Text(" Profil"),
                      Spacer()
                    ],
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(widget.context, '/user');
                  },
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.logout),
                      Text("Déconnection"),
                      Spacer()
                    ],
                  ),
                  onTap: () async {
                    await loggedInUserService.logout();
                    Navigator.pushReplacementNamed(widget.context, '/auth');
                  },
                ),
              ],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loggedInUserService.observableUsername.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Adjust the size as needed
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Ensure text does not overflow
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: 36,
                      width: 40,
                      child: Stack(
                        children: [
                          Obx(() {
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage:
                              NetworkImage(loggedInUserService.observableAvatar.value),
                            );
                          }),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 17.5,
                              height: 17.5,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  loggedInUserService.observableLevel.toString(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],      ),
    );
  }
}
