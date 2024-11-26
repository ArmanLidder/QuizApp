import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';
import '../../../services/theme_service.dart';

class FriendDisplayBox extends StatefulWidget {
  const FriendDisplayBox({Key? key}) : super(key: key);

  @override
  _FriendDisplayBoxState createState() => _FriendDisplayBoxState();
}

class _FriendDisplayBoxState extends State<FriendDisplayBox>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendService friendService = FriendService.instance;
  final ThemeService themeService = ThemeService.instance;
  final Map textFriends = TranslationService.instance.text['FRIENDS'];
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

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
    return SizedBox(
      height: 400,
      child: Obx(() {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeService.mainBackground.value,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: themeService.mixedMain.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Obx(() {
            final Map localMap = TranslationService.instance.text['FRIENDS'];

            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: localMap["TITLE"]),
                    Tab(text: localMap["PENDING_REQUESTS_TAB"]),
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
            );
          }),
        );
      }),
    );
  }

  Widget _buildFriendsList() {
    return Obx(() {
      if (loggedInUserService.friends.isEmpty) {
        return Center(
            child: Text(textFriends['EMPTY_FRIENDS_LIST'],
                style: TextStyle(color: themeService.mainAccent.value)));
      }

      return ListView.builder(
        itemCount: loggedInUserService.friends.length,
        itemBuilder: (context, index) {
          String friendId = loggedInUserService.friends[index];
          return SingleFriendInteractable(
            userId: friendId,
          );
        },
      );
    });
  }

  Widget _buildPendingRequestsList() {
    final Map textFriends = TranslationService.instance.text['FRIENDS'];

    return Obx(() {
      if (loggedInUserService.friendRequests.isEmpty) {
        return Center(
            child: Text(textFriends['NO_PENDING_REQUESTS'],
                style: TextStyle(color: themeService.mainAccent.value)));
      }

      return ListView.builder(
        itemCount: loggedInUserService.friendRequests.length,
        itemBuilder: (context, index) {
          String requestId = loggedInUserService.friendRequests[index];
          return SingleFriendInteractable(
            userId: requestId,
            isPending: true,
          );
        },
      );
    });
  }
}
