import 'package:flutter/material.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';
import '../../../services/theme_service.dart';
import 'friendsPopup.dart';

class FriendListDisplay extends StatefulWidget {
  final UserService userService = UserService.instance;
  final FriendService friendService = FriendService.instance;
  final List<String> friends;
  final List<FriendRequest> pendingRequests;
  final ThemeService themeService = ThemeService.instance;

  FriendListDisplay({required this.friends, required this.pendingRequests});

  @override
  _FriendListDisplayState createState() => _FriendListDisplayState();
}

class _FriendListDisplayState extends State<FriendListDisplay> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ThemeService themeService = ThemeService.instance;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amis",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: themeService.mainAccent.value,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: UserIdsRow(),
                    );
                  },
                );
              },
              icon: Icon(Icons.person_add, color: themeService.secondaryAccent.value),
              label: Text(
                "Ajouter",
                style: TextStyle(color: themeService.secondaryAccent.value),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeService.secondaryBackground.value,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
              color: themeService.mainBackground.value,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: themeService.mixedMain.withOpacity(0.5),
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
                  indicatorColor: themeService.secondaryBackground.value,
                  labelColor: themeService.secondaryBackground.value,
                  unselectedLabelColor: themeService.mainAccent.value,
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
        ),
      ],
    );
  }

  Widget _buildFriendsList() {
    return FutureBuilder<List<String>>(
      future: widget.friendService.getFriendList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading friends'));
        } else {
          List<String> friends = snapshot.data ?? [];
          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendId = friends[index];
              return SingleFriendInteractable(
                userId: friendId,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildPendingRequestsList() {
    return FutureBuilder<List<String>>(
      future: widget.friendService.getPendingList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading pending requests'));
        } else {
          List<String> pendingRequests = snapshot.data ?? [];
          return ListView.builder(
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              String requestId = pendingRequests[index];
              return SingleFriendInteractable(
                userId: requestId,
              );
            },
          );
        }
      },
    );
  }}
