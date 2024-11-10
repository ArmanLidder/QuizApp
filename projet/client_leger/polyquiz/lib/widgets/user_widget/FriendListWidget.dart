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

class _FriendListDisplayState extends State<FriendListDisplay> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure space between text and button
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amis",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add your onPressed functionality here
                print("Ajouter button pressed"); //TODO: addpopup
              },
              icon: Icon(Icons.person_add, color: Colors.white), // Person + icon
              label: Text(
                "Ajouter",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor : Colors.blue, // Button color
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
              ),
            ),
          ],
        ),
          SizedBox(
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
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: 'Friends'),
                    Tab(text: 'Pending'),
                  ],
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsList(),
                      _buildPendingRequestsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],


    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      itemCount: widget.friends.length,
      itemBuilder: (context, index) {
        String userId = widget.friends[index];

        return FutureBuilder<String>(
          future: widget.userService.getUserNameById(userId),
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
    );
  }

  Widget _buildPendingRequestsList() {
    return ListView.builder(
      itemCount: widget.pendingRequests.length,
      itemBuilder: (context, index) {
        String userId = widget.pendingRequests[index].fromUserId;

        return FutureBuilder<String>(
          future: widget.userService.getUserNameById(userId),
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
    );
  }
}
