import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String email;
  final String prestige;
  final String argent;

  ProfileCard({
    required this.username,
    required this.email,
    required this.prestige,
    required this.argent,
  });

  @override
  Widget build(BuildContext context) {
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
                  email,
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
