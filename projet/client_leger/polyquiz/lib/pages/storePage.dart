import 'package:flutter/material.dart';
import 'package:polyquiz/services/StoreService.dart';
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
  late String uid;
  User? userData;

  Map<String, List<Map<String, dynamic>>>? storeItems;

  @override
  void initState() {
    super.initState();
    _fetchStoreItems();
  }

  void _fetchStoreItems() async {
    var items = await storeService.browseStoreItems();
    String? id = await loggedInUserService.getUid();
    print(items); // Print the store browsing info
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
            context: context,),
        body: storeItems == null
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading indicator while fetching
            : SingleChildScrollView(child:
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MoneyCounter(),
                        Text("Themes: "),
                        Wrap(
                          spacing: 8.0, // Space between items horizontally
                          runSpacing: 8.0, // Space between items vertically
                          children: [
                          ThemeStoreList(
                                themes: storeItems!['themes']!, userId: this.uid)
                          ],
                        ),
                        SizedBox(height: 20),
                        Text("Images: "),
                            ImageStoreList(
                                themes: storeItems!['images']!, userId: this.uid),
                        SizedBox(height: 20),
                        Text("Récompenses: "),
                        RewardImageStoreList(
                            rewardItems: storeItems!['rewardImages']!, userId: this.uid),
                        SizedBox(height: 20),

                      ],
                    ),
                  ),)
      ),
    );
  }
}
