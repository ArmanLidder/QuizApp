import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/user_service.dart';

class FriendListDisplay extends StatefulWidget {
  final UserService userService = UserService.instance;
  final List<String> friends;
  final List<FriendRequest> pendingRequests;

  FriendListDisplay({required this.friends, required this.pendingRequests});

  @override
  _FriendListDisplayState createState() => _FriendListDisplayState();
}

class _FriendListDisplayState extends State<FriendListDisplay> {
  bool isFriendsSelected = true;
  final UserService userService = UserService.instance;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton('Friends', isFriendsSelected),
              _buildTabButton('Pending', !isFriendsSelected),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: isFriendsSelected
                  ? widget.friends.length
                  : widget.pendingRequests.length,
              itemBuilder: (context, index) {
                String userId = isFriendsSelected
                    ? widget.friends[index]
                    : widget.pendingRequests[index].fromUserId;

                // Use a FutureBuilder to handle the async call
                return FutureBuilder<String>(
                  future: widget.userService.getUserNameById(userId), // This is the async call
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Loading...'),
                        leading: Icon(Icons.person),
                      );
                    } else if (snapshot.hasError) {
                      return ListTile(
                        title: Text('Error loading name'),
                        leading: Icon(Icons.error),
                      );
                    } else {
                      return ListTile(
                        title: Text(snapshot.data ?? 'No name found'),
                        leading: Icon(Icons.person),
                      );
                    }
                  },
                );
              },
            ),
          )        ],
      ),
    ));
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFriendsSelected = title == 'Friends';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
