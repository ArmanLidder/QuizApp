import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/StoreService.dart';

class ThemeStoreItem extends StatelessWidget {
  final List<Map<String,  dynamic>> themes;
  final String userId;
  final StoreService storeService = Get.find();

  ThemeStoreItem({ required this.themes, required this.userId});

  @override
  Widget build(BuildContext context) {
    print(themes);
    List<Widget> items = [];
    themes.forEach((item) {
      print(item);
      ;
      Widget widget = StoreItem(
          itemId: item["id"],
          name: item["name"],
          cost: item["cost"],
          onBuy: ()=>{storeService.buy(userId,item["id"])} );
      items.add(widget);
    });
    return Column(
      children: items,
    );
  }
}

class StoreItem extends StatelessWidget {
  final String itemId;
  final String name;
  final num cost;
  final VoidCallback onBuy;

  const StoreItem({
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
        ElevatedButton(
          onPressed: onBuy,
          child: Text('Acheter ($cost) \$'),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
