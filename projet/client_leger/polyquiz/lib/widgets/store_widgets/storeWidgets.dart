import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

import '../../models/user.dart';

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
      print(item);
      Widget widget = ImageItem(
        itemId: item["id"],
        name: item["name"],
        cost: item["cost"],
        source: item["source"], // New field for image source
        onBuy: () async =>  {await storeService.buy(userId, item["id"])},
      );
      items.add(widget);
    });
    return Column(
      children: items,
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

class BuyButton extends StatefulWidget {
  final num cost;
  final Future<void> Function() onBuy; // Purchase callback
  final String itemId;
  BuyButton({
    required this.cost,
    required this.onBuy,
    required this.itemId,
  });

  @override
  _BuyButtonState createState() => _BuyButtonState();
}

class _BuyButtonState extends State<BuyButton> {
  final LoggedInUserService loggedInUserService = Get.find();
  final StoreService storeService = Get.find();
  bool alreadyOwns = false;
  bool canAfford = false;

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }

  Future<void> _updateButtonStatus() async {
    await loggedInUserService.reloadUser();
    User? user = loggedInUserService.getUser();
    num availableFunds = user?.currency ?? 0;
    bool ownsItem = await storeService.isOwned(user?.uid ?? "noIdInButtonWidget", widget.itemId);
    setState(() {
      alreadyOwns = ownsItem;
      canAfford = availableFunds >= widget.cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      storeService.purchaseTrigger;
      _updateButtonStatus(); // Update status on each change
      Color buttonColor;
      String buttonText;
      VoidCallback? buttonAction;

      if (alreadyOwns) {
        buttonColor = Colors.grey;
        buttonText = 'Déjà possédé';
        buttonAction = _updateButtonStatus; // Disable button if already owned
      } else if (canAfford) {
        buttonColor = Colors.green;
        buttonText = 'Acheter (${widget.cost}) \$';
        buttonAction = () async {
          await widget.onBuy(); // Call the purchase function
          _updateButtonStatus();
        };
      } else {
        buttonColor = Colors.red;
        buttonText = 'Pas assez de fonds (${widget.cost}) \$';
        buttonAction = _updateButtonStatus;
        ;
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
        onPressed: buttonAction,
        child: Text(buttonText),
      );
    });
  }
}

class MoneyCounter extends StatelessWidget {
  final LoggedInUserService loggedInUserService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Text(
        'Argent : ${loggedInUserService.observableCurrency.value} \$',
        style: TextStyle(fontSize: 20, color: Colors.black),
      );
    });
  }
}


