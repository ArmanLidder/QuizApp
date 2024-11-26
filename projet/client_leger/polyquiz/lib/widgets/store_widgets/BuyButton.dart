import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polyquiz/constants/eventNameTomessage.dart';
import 'package:polyquiz/services/StoreService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';

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
  bool get canAfford => loggedInUserService.observableCurrency >= widget.cost;
  Map get shopText => TranslationService.instance.text['SHOPPING'];

  @override
  void initState() {
    super.initState();
    _setupButtonState();
  }

  _setupButtonState () async {
    bool ownsItem = storeService.isOwned(widget.itemId);
    setState(() {
      alreadyOwns = ownsItem;
    });
  }
  Future<void> _updateButtonStatus() async {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      storeService.purchaseTrigger;
      Color buttonColor;
      String buttonText;
      VoidCallback? buttonAction;

      if (alreadyOwns) {
        buttonColor = Colors.grey;
        buttonText = shopText['OWNED'];
        buttonAction = _updateButtonStatus; // Disable button if already owned
      } else if (canAfford) {
        buttonColor = Colors.green;
        buttonText = '${shopText['BUY']} (${widget.cost}) \$';
        buttonAction = () async {
          setState(() {
            alreadyOwns = true;
          });
          widget.onBuy(); // Call the purchase function
          //_updateButtonStatus();
        };
      } else {
        buttonColor = Colors.red;
        buttonText = '${shopText['NOT_ENOUGH_FUNDS']} (${widget.cost}) \$';
        buttonAction = _updateButtonStatus;
        ;
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor,
          fixedSize: Size(200, 60),
        ),
        onPressed: buttonAction,
        child: Text(buttonText, textAlign: TextAlign.center,
            style:TextStyle(color: ThemeService.instance.mainAccent.value)
        ),

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
  bool get canAfford => loggedInUserService.observableCurrency >= widget.cost;
  Map get shopText => TranslationService.instance.text['SHOPPING'];
  bool get hasLevelNeeded => loggedInUserService.observableLevel >= widget.minLevel;

  @override
  void initState() {
    super.initState();
    _setupUpdateButton();
  }


  Future<void> _setupUpdateButton() async {
    bool ownsItem = await storeService.isOwned( widget.itemId);
    setState(() {
      alreadyOwns = ownsItem;
    });
  }

  Future<void> _updateButtonStatus() async {
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      storeService.purchaseTrigger;
      Color buttonColor;
      String buttonText;
      VoidCallback? buttonAction = ()=>{};

      if (alreadyOwns) {
        buttonColor = Colors.grey;
        buttonText = shopText['OWNED'];
        //buttonAction = _updateButtonStatus; // Disable button if already owned
      } else if (canAfford && hasLevelNeeded) {
        buttonColor = Colors.green;
        buttonText = '${shopText['BUY']} (${widget.cost}) \$';
        buttonAction = () async {
          print("preemptive button change");
          setState(() {
            alreadyOwns = true; //Temporaire localement, le set up avant d'avoir confirmation du serveurs
          });
          await widget.onBuy(); // Call the purchase function
          _updateButtonStatus();
        };
      } else {
        buttonColor = Colors.grey;
        final content =
        TranslationService.instance.languageValue.value == Language.fr
            ? "Débloqué au niveau"
            : "Unlocked at level";
        buttonText = '$content ${widget.minLevel}';
        buttonAction = _updateButtonStatus; // Disable button if requirements not met
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          fixedSize: Size(200, 60),
        ),
        onPressed: buttonAction,
        child: Center(child: Text(buttonText,
            textAlign: TextAlign.center,
            style:TextStyle(color: ThemeService.instance.mainAccent.value)
        )),
      );
    });
  }
}

class RewardThemeButton extends StatefulWidget {
  final num cost;
  final Future<void> Function() onBuy; // Purchase callback
  final String itemId;
  final num achievement; // Achievement to check

  RewardThemeButton({
    required this.cost,
    required this.onBuy,
    required this.itemId,
    required this.achievement,
  });

  @override
  _RewardThemeButtonState createState() => _RewardThemeButtonState();
}

class _RewardThemeButtonState extends State<RewardThemeButton> {
  final LoggedInUserService loggedInUserService = Get.find();
  final StoreService storeService = Get.find();
  Map get shopText => TranslationService.instance.text['SHOPPING'];
  List<String> get achievementText => TranslationService.instance.text['PROFILE']['ALL_ACHIEVEMENTS'];
  final ThemeService _themeService = ThemeService.instance;

  bool alreadyOwns = false;
  bool get canAfford => loggedInUserService.observableCurrency >= widget.cost;
  bool hasAchievement = false;

  @override
  void initState() {
    super.initState();
    _setupButtonStatus();
  }
  Future<void> _setupButtonStatus() async {
    bool ownsItem = await storeService.isOwned(widget.itemId);
    bool achievementUnlocked =
        loggedInUserService.observableAchievement.value.contains(widget.achievement) ?? false;
    setState(() {
      alreadyOwns = ownsItem;
      hasAchievement = achievementUnlocked;
    });
  }

  Future<void> _updateButtonStatus() async {
    bool achievementUnlocked =
        loggedInUserService.observableAchievement.value.contains(widget.achievement) ?? false;
    setState(() {
      hasAchievement = achievementUnlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      storeService.purchaseTrigger;
      Color buttonColor;
      String buttonText;
      VoidCallback? buttonAction;

      if (alreadyOwns) {
        buttonColor = Colors.grey;
        buttonText = shopText['OWNED'];
        buttonAction = _updateButtonStatus; // Disable button if already owned
      } else if (hasAchievement) {
        if (canAfford) {
          buttonColor = Colors.green;
          buttonText = '${shopText['BUY']} (${widget.cost}) \$';
          buttonAction = () async {
            setState(() {
              alreadyOwns = true;
            });
            await widget.onBuy(); // Call the purchase function
            _updateButtonStatus();
          };
        } else {
          buttonColor = Colors.red;
          buttonText = shopText['NOT_ENOUGH_FUNDS'] + " (${widget.cost}) \$";
          buttonAction = _updateButtonStatus; // Disable button if insufficient funds
        }
      } else {
        buttonColor = Colors.grey;
        final content =
        TranslationService.instance.languageValue.value == Language.fr
            ? "Débloqué à l'exploit"
            : "Unlocked at exploit";

        buttonText = '$content ${achievementText[(widget.achievement as int) - 1]}';
        buttonAction = _updateButtonStatus; // Disable button if achievement not met
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          fixedSize: Size(200, 60),
        ),
        onPressed: buttonAction,
        child: Center(child: Text(buttonText,
            style: TextStyle(color: _themeService.mainAccent.value))),



      );
    });
  }
}

class RewardCashButton extends StatefulWidget {
  final num cost;
  final Future<void> Function() onClaim; // Claim callback
  final String itemId;
  final num achievement; // Achievement to check

  RewardCashButton({
    required this.cost,
    required this.onClaim,
    required this.itemId,
    required this.achievement,
  });

  @override
  _RewardCashButtonState createState() => _RewardCashButtonState();
}

class _RewardCashButtonState extends State<RewardCashButton> {
  final LoggedInUserService loggedInUserService = Get.find();
  final StoreService storeService = Get.find();
  final ThemeService _themeService = ThemeService.instance;
  Map get shopText => TranslationService.instance.text['SHOPPING'];
  List<String> get achievementText =>
      TranslationService.instance.text['PROFILE']['ALL_ACHIEVEMENTS'];

  bool alreadyClaimed = false;
  bool hasAchievement = false;

  @override
  void initState() {
    super.initState();
    _setupButtonStatus();
  }

  Future<void> _setupButtonStatus() async {
    await loggedInUserService.reloadUser();
    final user = loggedInUserService.getUser();
    bool ownsItem = await storeService.isOwned(
        widget.itemId);
    bool achievementUnlocked =
        user?.achievements.contains(widget.achievement) ?? false;

    setState(() {
      alreadyClaimed = ownsItem;
      hasAchievement = achievementUnlocked;
    });
  }
  Future<void> _updateButtonStatus() async {
    await loggedInUserService.reloadUser();
    final user = loggedInUserService.getUser();
    bool achievementUnlocked =
        user?.achievements.contains(widget.achievement) ?? false;
    setState(() {
      hasAchievement = achievementUnlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      storeService.purchaseTrigger;
      Color buttonColor;
      String buttonText;
      VoidCallback? buttonAction;

      if (alreadyClaimed) {
        buttonColor = Colors.grey;
        buttonText = shopText['CLAIMED']; // "Réclamée"
        buttonAction = _updateButtonStatus; // Disable button if already claimed

      } else if (hasAchievement) {
        buttonColor = Colors.green;
        buttonText = shopText['CLAIM']; // "Réclamer"
        buttonAction = () async {
          setState(() {
            alreadyClaimed = true;
          });
          widget.onClaim(); // Call the claim function
          _updateButtonStatus();
        };
      } else {
        buttonColor = Colors.grey;
        final content =
        TranslationService.instance.languageValue.value == Language.fr
            ? "Débloqué à l'exploit  "
            : "Unlocked at achievement ";
        buttonText =
        '$content ${achievementText[(widget.achievement - 1) as int]}';
        buttonAction = _updateButtonStatus; // Disable button if achievement not met
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          fixedSize: Size(200, 60),
        ),
        onPressed: buttonAction,
        child: Center(
            child: Text(buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(color: _themeService.mainAccent.value))),
      );
    });
  }
}
