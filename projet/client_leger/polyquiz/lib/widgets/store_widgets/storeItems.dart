import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/constants/themesNamesToColorArray.dart';
import 'BuyButton.dart';


class ThemeItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final Future<void> Function() onBuy;

  const ThemeItem.ThemeStoreItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.onBuy,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(themeColors[name]?[0]);
    return Column(
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
          name,
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 8),
        // Buy button with cost
        BuyButton(cost: cost, onBuy: onBuy, itemId: itemId,),
        SizedBox(height: 20),
      ],
    );
  }
}

class ImageItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final String source; // New field for image source
  final Future<void> Function() onBuy;

  const ImageItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.source,
    required this.onBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 8),
        // Buy button with cost
        BuyButton(cost: cost, onBuy: onBuy, itemId: itemId),
        SizedBox(height: 20),
      ],
    );
  }
}

class RewardImageItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final String source; // New field for image source
  final Future<void> Function() onBuy;
  final num minPrestige;
  final num minLevel;

  const RewardImageItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.source,
    required this.onBuy,
    required this.minLevel,
    required this.minPrestige
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 8),
        ImageRewardButton(cost: cost, onBuy: onBuy, itemId: itemId, minLevel: this.minLevel),
        SizedBox(height: 20),
      ],
    );
  }
}

class RewardThemeItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final num achievement;
  final Future<void> Function() onBuy;

  const RewardThemeItem({
    Key? key,
    required this.itemId,
    required this.name,
    required this.cost,
    required this.onBuy,
    required this.achievement,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
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
          name,
          style: TextStyle(color: Colors.black),
        ),
        SizedBox(height: 8),
        // Buy button with cost
        RewardThemeButton(cost: cost, onBuy: onBuy, itemId: itemId, achievement: 4,),
        SizedBox(height: 20),
      ],
    );
  }
}
