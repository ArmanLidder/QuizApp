import 'package:flutter/material.dart';

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
    return Column(
      children: [
        // Purple circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.purple,
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
        RewardButton(cost: cost, onBuy: onBuy, itemId: itemId, minLevel: this.minLevel, minPrestige: this.minPrestige,),
        SizedBox(height: 20),
      ],
    );
  }
}
