import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/widgets/observer_widgets/observation_selector.dart';
import 'package:polyquiz/widgets/observer_widgets/observer_counter.dart';
import 'package:polyquiz/widgets/user_widget/friend/appBarFriendIcon.dart';
import 'package:polyquiz/widgets/user_widget/settings/SettingsPopup.dart';

import '../services/translationService.dart';

class FancyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isGamePage;
  final bool isObserver;
  final bool canLeaveFromAppBar;
  final BuildContext context;
  FancyAppBar(
      {required this.context,
      this.canLeaveFromAppBar = false,
      this.isGamePage = false,
      this.isObserver = false});

  @override
  _FancyAppBarState createState() => _FancyAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(60.0); // Adjust the height if needed
}

class _FancyAppBarState extends State<FancyAppBar> {
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  late String imageUrl; // Use late keyword to initialize later
  final ThemeService themeService = ThemeService.instance;
  Map get MenuText => TranslationService.instance.text["AVATAR_CLICK_MENU"];

  @override
  void initState() {
    super.initState();
    imageUrl = loggedInUserService
        .observableAvatar.value; // Initialize with the source image URL
  }

  Widget getObservationWidget() {
    if (widget.isObserver)
      return ObservationSelector();
    else
      return ObserverCounter();
  }

  Widget getTitleWidget() {
    return Center(
        child: InkWell(
      onTap: () {
        if (widget.canLeaveFromAppBar) {
          Navigator.pushReplacementNamed(widget.context, '/home');
        }
      },
      child: Text(
        "PolyQuiz",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    ));
  }

  Widget getCenterWidget() {
    return Row(
      children: [
        if (widget.isGamePage) getObservationWidget(),
        Expanded(
          child: getTitleWidget(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext barContext) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(38, 99, 235, 1),
            Color.fromRGBO(167, 85, 246, 1)
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: AppBar(
        title: getCenterWidget(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: PendingRequestsWidget(),
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SettingsPopup(
                        isGamePage: widget
                            .isGamePage), // Your custom settings popup widget
                  );
                },
              );
            },
            child: Icon(
              Icons.settings,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: PopupMenuButton<int>(
              color: themeService.container.value,
              onSelected: (value) {},
              itemBuilder: (context) => widget.canLeaveFromAppBar
                  ? [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.person,
                                color: themeService.mainAccent.value),
                            Text(MenuText["PROFIL"],
                                style: TextStyle(
                                    color: themeService.mainAccent.value)),
                            Spacer()
                          ],
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              widget.context, '/user');
                        },
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.logout,
                              color: themeService.mainAccent.value,
                            ),
                            Text(MenuText["DISCONNECT"],
                                style: TextStyle(
                                    color: themeService.mainAccent.value)),
                            Spacer()
                          ],
                        ),
                        onTap: () async {
                          loggedInUserService.logout();
                          Navigator.pushReplacementNamed(
                              widget.context, '/auth');
                        },
                      ),
                    ]
                  : [],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 36,
                    width: 40,
                    child: Stack(
                      children: [
                        Obx(() {
                          return CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                loggedInUserService.observableAvatar.value),
                          );
                        }),
                        Positioned(
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
                              child: Obx(() {
                                return Text(
                                  loggedInUserService.observableLevel
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    return Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 10.0,
                          color: Colors.white,
                        ),
                        Text(
                          loggedInUserService.observableCurrency.value
                              .toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10, // Adjust the size as needed
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow
                              .ellipsis, // Ensure text does not overflow
                          maxLines: 1,
                        ),
                      ],
                    );
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
