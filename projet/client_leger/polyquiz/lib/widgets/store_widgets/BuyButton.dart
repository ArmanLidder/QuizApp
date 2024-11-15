import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/constants/eventNameTomessage.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

import '../../models/user.dart';


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


class ImageRewardButton extends StatefulWidget {
  final num cost;
  final Future<void> Function() onBuy; // Purchase callback
  final String itemId;
  final num minLevel;
  ImageRewardButton({
    required this.cost,
    required this.onBuy,
    required this.itemId,
    required this.minLevel,
  });

  @override
  _ImageRewardButtonState createState() => _ImageRewardButtonState();
}


class _ImageRewardButtonState extends State<ImageRewardButton> {
  final LoggedInUserService loggedInUserService = Get.find();
  final StoreService storeService = Get.find();
  bool alreadyOwns = false;
  bool canAfford = false;
  bool meetsPrestigeLevel = false;

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }

  Future<void> _updateButtonStatus() async {
    await loggedInUserService.reloadUser();
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
    bool ownsItem = await storeService.isOwned(loggedInUserService.getUid() ?? "noIdInButtonWidget", widget.itemId);
    bool hasRequiredLevel = (loggedInUserService.observableLevel.value ?? 0) >= widget.minLevel;

    setState(() {
      alreadyOwns = ownsItem;
      canAfford = availableFunds >= widget.cost;
      meetsPrestigeLevel =  hasRequiredLevel;
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
      } else if (canAfford && meetsPrestigeLevel) {
        buttonColor = Colors.green;
        buttonText = 'Acheter (${widget.cost}) \$';
        buttonAction = () async {
          await widget.onBuy(); // Call the purchase function
          _updateButtonStatus();
        };
      } else {
        buttonColor = Colors.grey;
        buttonText = 'Débloqué au niveau ${widget.minLevel}';
        buttonAction = _updateButtonStatus; // Disable button if requirements not met
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
        onPressed: buttonAction,
        child: Text(buttonText),
      );
    });
  }
}

class RewardThemeButton extends StatefulWidget {
  final num cost;
  final Future<void> Function() onBuy; // Purchase callback
  final String itemId;
  final num achievement; // Achievement to check
  final Future<void> Function()? onUnlock; // Callback for unlocking

  RewardThemeButton({
    required this.cost,
    required this.onBuy,
    required this.itemId,
    required this.achievement,
    this.onUnlock,
  });

  @override
  _RewardThemeButtonState createState() => _RewardThemeButtonState();
}

class _RewardThemeButtonState extends State<RewardThemeButton> {
  final LoggedInUserService loggedInUserService = Get.find();
  final StoreService storeService = Get.find();

  bool alreadyOwns = false;
  bool canAfford = false;
  bool hasAchievement = false;

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }

  Future<void> _updateButtonStatus() async {
    await loggedInUserService.reloadUser();
    final user = loggedInUserService.getUser();
    num availableFunds = user?.currency ?? 0;
    bool ownsItem = await storeService.isOwned(user?.uid ?? "noIdInRewardButtonWidget", widget.itemId);
    bool achievementUnlocked = user?.achievements.contains(widget.achievement) ?? false;

    setState(() {
      alreadyOwns = ownsItem;
      canAfford = availableFunds >= widget.cost;
      hasAchievement = achievementUnlocked;
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
        buttonAction = null; // Disable button if already owned
      } else if (hasAchievement) {
        if (canAfford) {
          buttonColor = Colors.green;
          buttonText = 'Acheter (${widget.cost}) \$';
          buttonAction = () async {
            await widget.onBuy(); // Call the purchase function
            _updateButtonStatus();
          };
        } else {
          buttonColor = Colors.red;
          buttonText = 'Pas assez de fonds (${widget.cost}) \$';
          buttonAction = null; // Disable button if insufficient funds
        }
      } else {
        buttonColor = Colors.grey;
        buttonText = 'Débloqué à l\'exploit ${widget.achievement}';
        buttonAction = null; // Disable button if achievement not met
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
        onPressed: buttonAction,
        child: Text(buttonText),
      );
    });
  }
}
