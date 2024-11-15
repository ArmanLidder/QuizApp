import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';
import '../../../services/LanguageService.dart';
import '../../../services/theme_service.dart';
import 'friendsPopup.dart';

class FriendListDisplay extends StatefulWidget {
  final UserService userService = UserService.instance;
  final FriendService friendService = FriendService.instance;
  final List<String> friends;
  final List<FriendRequest> pendingRequests;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;

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
              child: Obx(()  {
                return Text(
                  widget.ls.friendsLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeService.mainAccent.value,
                  ),
                );}),),
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
                widget.ls.addLabel,
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
        child: Obx(() {
          return Container(
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
                    Tab(text: widget.ls.friendsLabel),
                    Tab(text: widget.ls.pendingLabel),
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
          );})
        ),
      ],
    );
  }

  Widget _buildFriendsList() {
    return Obx(() {
      return ListView.builder(
        itemCount: widget.friendService.friends.length,
        itemBuilder: (context, index) {
          String friendId = widget.friendService.friends[index];
          return SingleFriendInteractable(
            userId: friendId,
          );
        },
      );
    });
  }

  Widget _buildPendingRequestsList() {
    // You don't need FutureBuilder here since we're using Obx with RxList
    return Obx(() {
      // If the pending requests list is empty or null, show a message
      if (widget.friendService.friendRequests.isEmpty) {
        return Center(child: Text('No pending requests'));
      }

      return ListView.builder(
        itemCount: widget.friendService.friendRequests.length,
        itemBuilder: (context, index) {
          String requestId = widget.friendService.friendRequests[index];
          return SingleFriendInteractable(
            userId: requestId,
          );
        },
      );
    });
  }

}
