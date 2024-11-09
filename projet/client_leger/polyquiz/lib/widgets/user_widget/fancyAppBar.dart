import 'package:flutter/material.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class FancyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String sourceImgUrl;
  final String name;
  final BuildContext context;

  FancyAppBar({required this.sourceImgUrl, required this.name, required this.context});

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
    imageUrl = widget.sourceImgUrl; // Initialize with the source image URL
  }

  Future<void> _imageChangeButton() async {
    await loggedInUserService.updateProfilePicture();
    setState(() {
      imageUrl = loggedInUserService.getUser()!.avatar; // Update accordingly
    });
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
            child: Row(
              children: [
                //IconButton(
                //  icon: Icon(Icons.create_outlined),
                //  onPressed: _imageChangeButton, // Call the async function
                //),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Adjust the size as needed
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4), // Space between the text and the image
                    CircleAvatar(
                      radius: 17.5,
                      backgroundImage: NetworkImage(imageUrl), // Use the updated variable
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
