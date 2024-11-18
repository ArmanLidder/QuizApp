import 'package:flutter/material.dart';
import 'package:polyquiz/services/global_navigation_service.dart';
import 'package:polyquiz/services/translationService.dart';

class CancelBtn extends StatelessWidget {
  final GlobalNavigationService _globalNavigationService =
      GlobalNavigationService();

  CancelBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        _globalNavigationService.navigateTo('/home');
      },
      child: Text(
        TranslationService.instance.text['CONFIRMATION_DIALOG']['CANCEL'],
        style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 20),
      ),
      style: TextButton.styleFrom(
          textStyle: TextStyle(fontWeight: FontWeight.normal),
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Color.fromRGBO(246, 53, 53, 1)),
    );
  }
}
