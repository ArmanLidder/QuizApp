import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/store_widgets/storeItems.dart';

import '../../models/user.dart';
import 'BuyButton.dart';

class MoneyCounter extends StatelessWidget {
  final LoggedInUserService loggedInUserService = Get.find();
  final ThemeService _themeService = ThemeService.instance;
  Map get shopText => TranslationService.instance.text['SHOPPING'];
  Map get profileText => TranslationService.instance.text['PROFILE'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Center(
        child: Text(
          '${shopText['CURRENCY']} : ${loggedInUserService.observableCurrency.value} \$',
          style: TextStyle(fontSize: 20, color: _themeService.mainAccent.value),
        ),
      );
    });
  }
}

class ThemeStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> themes;
  final String userId;
  final StoreService storeService = Get.find();

  ThemeStoreList({required this.themes, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    themes.forEach((item) {
      ;
      Widget widget = ThemeItem.ThemeStoreItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        onBuy: () async => {await storeService.buy( item["id"])},
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
    List<Widget> items = [];
    themes.forEach((item) {
      Widget widget = ImageItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        source: item["source"], // New field for image source
        onBuy: () async => {await storeService.buy( item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    return  Wrap(
      alignment: WrapAlignment.start,
      children: items,
        );
  }
}

class RewardImageStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> rewardImages;
  final List<Map<String, dynamic>> rewardThemes;
  final String userId;
  final StoreService storeService = Get.find();

  RewardImageStoreList.RewardStoreList({ required this.rewardImages,required this.rewardThemes, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    rewardImages.forEach((item) {
      Widget widget = RewardImageItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        source: item["source"], // New field for image source
        minLevel: item["minLevel"],
        onBuy: () async => {await storeService.buy( item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    rewardThemes.forEach((item) {
      Widget widget = RewardThemeItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        achievement: item["achievement"],
        onBuy: () async => {await storeService.buy(item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });

    return Wrap(
      alignment: WrapAlignment.start,
      children: items,
        );
  }
}

class RewardThemeStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> rewardThemes;
  final String userId;
  final StoreService storeService = Get.find();

  RewardThemeStoreList({required this.rewardThemes, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    rewardThemes.forEach((item) {
      Widget widget = RewardThemeItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        achievement: item["achievement"],
        onBuy: () async => {await storeService.buy(item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    return
         Wrap(
           alignment: WrapAlignment.start,
           children: items,
        );
  }
}

class RewardCashStoreList extends StatelessWidget {
  final List<Map<String, dynamic>> cashItems;
  final String userId;
  final StoreService storeService = Get.find();

  RewardCashStoreList({required this.cashItems, required this.userId});

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    cashItems.sort((a, b) => a["achievement"].compareTo(b["achievement"]));
    cashItems.forEach((item) {
      Widget widget = RewardCashItem(
        itemId: item["id"],
        cost: item["cost"],
        achievement: item["achievement"],
        onBuy: () async => {await storeService.buy(item["id"])},
      );
      items.add(widget);
      items.add(SizedBox(
        width: 5,
      ));
    });
    return
        Wrap(
          alignment: WrapAlignment.start,
          children: items,
        );
  }
}
