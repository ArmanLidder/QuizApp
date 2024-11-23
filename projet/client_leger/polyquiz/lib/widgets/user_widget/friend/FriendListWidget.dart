import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/friendService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import '../../../services/LanguageService.dart';
import '../../../services/theme_service.dart';
import 'friendTabMenu.dart';
import 'friendsPopup.dart';

class FriendListDisplay extends StatefulWidget {
  final FriendService friendService = FriendService.instance;
  final ThemeService themeService = ThemeService.instance;
  final LanguageService ls = LanguageService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  @override
  _FriendListDisplayState createState() => _FriendListDisplayState();
}

class _FriendListDisplayState extends State<FriendListDisplay>
    with SingleTickerProviderStateMixin {
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
              child: Obx(() {
                return Text(
                  widget.ls.friendsLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeService.mainAccent.value,
                  ),
                );
              }),
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
              icon: Icon(Icons.person_add,
                  color: themeService.secondaryAccent.value),
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
        FriendDisplayBox(),
      ],
    );
  }
}
