import 'package:flutter/material.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:get/get.dart';
import 'package:polyquiz/widgets/store_widgets/storeLists.dart';

import 'package:polyquiz/widgets/store_widgets/storeLists.dart';
//import 'package:polyquiz/widgets/store_widgets/themeWidget.dart';
import '../models/user.dart';
import '../widgets/fancyAppBar.dart';

class Storepage extends StatefulWidget {
  @override
  _StorepageState createState() => _StorepageState();
}

class _StorepageState extends State<Storepage> {
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final StoreService storeService = Get.find();
  final ThemeService _themeService = ThemeService.instance;
  late String uid;
  User? userData;
  Map get shopText => TranslationService.instance.text['SHOPPING'];

  Map<String, List<Map<String, dynamic>>>? storeItems;

  @override
  void initState() {
    super.initState();
    _fetchStoreItems();
  }

  void _fetchStoreItems() async {
    var items = await storeService.browseStoreItems();
    String? id = await loggedInUserService.getUid();
    setState(() {
      storeItems = items; // Update the state with fetched items
      uid = id!;
    });
  }

  @override
  Widget build(BuildContext context) {
    this.userData = this.loggedInUserService.getUser();

    return MaterialApp(
      home: Scaffold(
          appBar: FancyAppBar(
            context: context,
          ),
          backgroundColor: _themeService.mainBackground.value,
          body: storeItems == null
              ? Center(
                  child:
                      CircularProgressIndicator()) // Show loading indicator while fetching
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MoneyCounter(),
                        Text(shopText['THEMES'],
                            style: TextStyle(
                                color: _themeService.mainAccent.value)),
                        Wrap(
                          spacing: 8.0, // Space between items horizontally
                          runSpacing: 8.0, // Space between items vertically
                          children: [
                            ThemeStoreList(
                                themes: storeItems!['themes']!,
                                userId: this.uid)
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(shopText['IMAGES'],
                            style: TextStyle(
                                color: _themeService.mainAccent.value)),
                        ImageStoreList(
                            themes: storeItems!['images']!, userId: this.uid),
                        SizedBox(height: 20),
                        Text(
                            TranslationService.instance.languageValue.value ==
                                    Language.fr
                                ? "Récompenses: "
                                : "Prizes: ",
                            style: TextStyle(
                                color: _themeService.mainAccent.value)),
                        RewardImageStoreList(
                            rewardItems: storeItems!['rewardImages']!,
                            userId: this.uid),
                        SizedBox(height: 20),
                        RewardThemeStoreList(
                            rewardItems: storeItems!['rewardThemes']!,
                            userId: this.uid),
                        SizedBox(height: 20),
                        Text(
                            TranslationService.instance.languageValue.value ==
                                    Language.fr
                                ? "Récompenses d'exploit: "
                                : "Achievements rewards: ",
                            style: TextStyle(
                                color: _themeService.mainAccent.value)),
                        RewardCashStoreList(
                            cashItems: storeItems!['rewardCurrency']!,
                            userId: this.uid),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                )),
    );
  }
}
