import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

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
            "          PolyQuiz",
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<int>(
        onSelected: (value) {
          // Handle the popup menu selection here
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Profile"),
            onTap: () {Navigator.pushReplacementNamed(widget.context, '/user');}, // Placeholder onPressed for "Profile"
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Log Out"),
            onTap: () {Navigator.pushReplacementNamed(widget.context, '/auth');}, // Placeholder onPressed for "Log Out"
          ),
        ],
            child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loggedInUserService.user!.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Adjust the size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      width: 40,
                      child: Stack(
                        children: [
                          Obx(() {
                            return CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(loggedInUserService.observableAvatar.value),
                            );
                          }),                          Positioned(
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
                                  loggedInUserService.getUser()!.level.toString(),
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

                    )// Space between the text and the image
                  ],
                ),
            ),
          )
        ],
      ),
    );
  }
}
