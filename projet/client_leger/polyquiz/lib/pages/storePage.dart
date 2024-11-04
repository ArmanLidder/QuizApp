import 'package:flutter/material.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:get/get.dart';
import 'package:polyquiz/widgets/store_widgets/themeWidget.dart';

class Storepage extends StatefulWidget {
  @override
  _StorepageState createState() => _StorepageState();
}

class _StorepageState extends State<Storepage> {
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final StoreService storeService = Get.find();
   late String uid;
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Store Page')),
        body: storeItems == null
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Themes: "),
              Row(
                children: [
                  ThemeStoreList(themes: storeItems!['themes']!,  userId: this.uid)
                ],
              ),
              SizedBox(height: 20),
              Text("Images: "),

              Row(
                children: [
                  ImageStoreList(themes: storeItems!['images']!,  userId: this.uid)

                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

