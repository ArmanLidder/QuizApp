import 'package:flutter/material.dart';

class FancyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String imageUrl;
  final String name;

  FancyAppBar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
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
              child: Text("          OnlyQuizz", //TODO: arreter d'etre con
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ))),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    this.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10, // Adjust the size as needed
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4), // Space between the text and the image
                  CircleAvatar(
                    radius: 17.5,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(60.0); // Adjust the height if needed
}
