import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/widgets/store_widgets/storeItems.dart';

import '../../models/user.dart';
import 'BuyButton.dart';
class MoneyCounter extends StatelessWidget {
  final LoggedInUserService loggedInUserService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      User? user = loggedInUserService.getUser(); // Retrieve the user object
      num prestige = user?.prestige ?? 0; // Default to 0 if prestige is null
      num level = user?.level ?? 0; // Default to 0 if level is null

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Argent : ${loggedInUserService.observableCurrency.value} \$',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          Text(
            'Prestige : $prestige',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          Text(
            'Niveau : $level',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ],
      );
    });
  }
}

class ThemeStoreList extends StatelessWidget {
  final List<Map<String,  dynamic>> themes;
  final String userId;
  final StoreService storeService = Get.find();

  ThemeStoreList({ required this.themes, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    themes.forEach((item) {
      print(item);
      ;
      Widget widget = ThemeItem.ThemeStoreItem(
          itemId: item["id"],
          name: item["name"],
          cost: item["cost"],
          onBuy: () async =>  {await storeService.buy(userId, item["id"])},
      );
      items.add(widget);
    });
    return Column(
      children: items,
    );
  }
}
class ImageStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> themes;
  final String userId;
  final StoreService storeService = Get.find();

  ImageStoreList({required this.themes, required this.userId});

  @override
  Widget build(BuildContext context) {
    print(themes);
    List<Widget> items = [];
    themes.forEach((item) {
      Widget widget = ImageItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        source: item["source"], // New field for image source
        onBuy: () async =>  {await storeService.buy(userId, item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    return  Center(child:Wrap(
      children: items,
    ));
  }
}
class RewardImageStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> rewardItems;
  final String userId;
  final StoreService storeService = Get.find();

  RewardImageStoreList({required this.rewardItems, required this.userId});

  @override
  Widget build(BuildContext context) {
    print(rewardItems);
    List<Widget> items = [];
    rewardItems.forEach((item) {
      Widget widget = RewardImageItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        source: item["source"], // New field for image source
        minLevel: item["minLevel"],
        minPrestige: item["minPrestige"],
        onBuy: () async =>  {await storeService.buy(userId, item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    return  Center(child:Wrap(
      children: items,
    ));
  }
}



