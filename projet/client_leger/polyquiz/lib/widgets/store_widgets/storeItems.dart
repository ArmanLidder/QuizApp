import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/constants/themesNamesToColorArray.dart';
import 'package:polyquiz/services/translationService.dart';
import 'BuyButton.dart';

class ThemeItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final Future<void> Function() onBuy;
  final ThemeService _themeService = ThemeService.instance;
  ThemeItem.ThemeStoreItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.onBuy,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: _themeService.container.value,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Purple circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeColors[name]?[0],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 8),
          // Item name in white
          Text(
            TranslationService.instance.text["SETTINGS"][name],
            style: TextStyle(color: _themeService.mainAccent.value),
          ),
          SizedBox(height: 8),
          // Buy button with cost
          BuyButton(
            cost: cost,
            onBuy: onBuy,
            itemId: itemId,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ImageItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final String source; // New field for image source
  final Future<void> Function() onBuy;
  final ThemeService _themeService = ThemeService.instance;

  ImageItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.source,
    required this.onBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: _themeService.container.value,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Circle with image inside
          ClipOval(
            child: Image.network(
              source,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          // Item name in black
          Text(
            name,
            style: TextStyle(color: _themeService.mainAccent.value),
          ),
          SizedBox(height: 8),
          // Buy button with cost
          BuyButton(cost: cost, onBuy: onBuy, itemId: itemId),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class RewardImageItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final String source; // New field for image source
  final Future<void> Function() onBuy;
  final num minLevel;
  final ThemeService _themeService = ThemeService.instance;

  RewardImageItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.source,
    required this.onBuy,
    required this.minLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: _themeService.container.value,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ClipOval(
            child: Image.network(
              source,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          // Item name in black
          Text(
            name,
            style: TextStyle(color: _themeService.mainAccent.value),
          ),
          SizedBox(height: 8),
          ImageRewardButton(
              cost: cost,
              onBuy: onBuy,
              itemId: itemId,
              minLevel: this.minLevel),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class RewardThemeItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final num achievement;
  final Future<void> Function() onBuy;
  final ThemeService _themeService = ThemeService.instance;

  RewardThemeItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.onBuy,
    required this.achievement,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: _themeService.container.value,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          // Purple circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: themeColors[name]?[0],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 8),
          // Item name in white
          Text(
            TranslationService.instance.text["SETTINGS"][name],
            style: TextStyle(color: _themeService.mainAccent.value),
          ),
          SizedBox(height: 8),
          // Buy button with cost
          RewardThemeButton(
            cost: cost,
            onBuy: onBuy,
            itemId: itemId,
            achievement: achievement,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class RewardCashItem extends StatelessWidget {
  final String itemId;
  final num cost;
  final num achievement;
  final Future<void> Function() onBuy;
  ThemeService _themeService = ThemeService.instance;

  RewardCashItem({
    Key? key,
    required this.itemId,
    required this.cost,
    required this.onBuy,
    required this.achievement,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: _themeService.container.value,
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [


          ClipOval(
            child: Image.network(
              "https://firebasestorage.googleapis.com/v0/b/polyquiz-app.appspot.com/o/shopGIFS%2FmoneyBag.png?alt=media&token=2b17df15-3c81-4f39-b27f-03c96b2f8f84",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8,),
          Text(
            (-cost).toString() + " \$",
            style: TextStyle(color: _themeService.mainAccent.value),
          ),

          SizedBox(height: 8),
          // Buy button with cost
          RewardCashButton(
              cost: cost,
              onClaim: onBuy,
              itemId: itemId,
              achievement: achievement),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
