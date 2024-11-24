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
  bool canAfford = false;
  Map get shopText => TranslationService.instance.text['SHOPPING'];

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }

  _setupButtonState () async {
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
    bool ownsItem = await storeService.isOwned(
        loggedInUserService.getUid()!, widget.itemId);
    setState(() {
      //alreadyOwns = ownsItem;
      canAfford = availableFunds >= widget.cost;
    });
    }
  Future<void> _updateButtonStatus() async {
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
    setState(() {
      canAfford = availableFunds >= widget.cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    _setupButtonState(); // Update status on each change
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
          await widget.onBuy(); // Call the purchase function
          //_updateButtonStatus();
        };
      } else {
        buttonColor = Colors.red;
        buttonText = '${shopText['NOT_ENOUGH_FUNDS']} (${widget.cost}) \$';
        buttonAction = _updateButtonStatus;
        ;
      }

      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
        onPressed: buttonAction,
        child: Text(buttonText, textAlign: TextAlign.center),
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
  bool hasLevelNeeded = false;
  Map get shopText => TranslationService.instance.text['SHOPPING'];

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }


  Future<void> _setupUpdateButton() async {
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
    bool ownsItem = await storeService.isOwned(
        loggedInUserService.getUid() ?? "noIdInButtonWidget", widget.itemId);
    bool hasRequiredLevel =
        (loggedInUserService.observableLevel.value ?? 0) >= widget.minLevel;
    setState(() {
      //alreadyOwns = ownsItem;
      canAfford = availableFunds >= widget.cost;
      hasLevelNeeded = hasRequiredLevel;
    });
  }

    Future<void> _updateButtonStatus() async {
    num availableFunds = loggedInUserService.observableCurrency.value ?? 0;
    bool hasRequiredLevel =
        (loggedInUserService.observableLevel.value ?? 0) >= widget.minLevel;
    setState(() {
      canAfford = availableFunds >= widget.cost;
      hasLevelNeeded = hasRequiredLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    _setupUpdateButton(); // Update status on each change
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
        child: Center(child: Text(buttonText, textAlign: TextAlign.center)),
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
  Map get shopText => TranslationService.instance.text['SHOPPING'];
  List<String> get achievementText => TranslationService.instance.text['PROFILE']['ALL_ACHIEVEMENTS'];
  final ThemeService _themeService = ThemeService.instance;

  bool alreadyOwns = false;
  bool canAfford = false;
  bool hasAchievement = false;

  @override
  void initState() {
    super.initState();
    _updateButtonStatus();
  }

  Future<void> _updateButtonStatus() async {
    bool ownsItem = await storeService.isOwned(
        loggedInUserService.getUid()!, widget.itemId);
    bool achievementUnlocked =
        loggedInUserService.observableAchievement.value.contains(widget.achievement) ?? false;

    setState(() {
      alreadyOwns = ownsItem;
      canAfford = loggedInUserService.observableCurrency.value >= widget.cost;
      hasAchievement = achievementUnlocked;
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateButtonStatus(); // Update status on each change
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
    _updateButtonStatus();
  }

  Future<void> _setupButtonStatus() async {
    await loggedInUserService.reloadUser();
    final user = loggedInUserService.getUser();
    bool ownsItem = await storeService.isOwned(
        user?.uid ?? "noIdInRewardCashButtonWidget", widget.itemId);
    bool achievementUnlocked =
        user?.achievements.contains(widget.achievement) ?? false;

    setState(() {
      alreadyClaimed = ownsItem;
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
    _setupButtonStatus(); // Update status on each change
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
          await widget.onClaim(); // Call the claim function
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
