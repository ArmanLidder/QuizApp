import 'package:flutter/material.dart';
import 'package:polyquiz/services/theme_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/services/userInfoValidation.dart';

import '../../services/logged_in_user_service.dart';

class ChangeNamePopup extends StatefulWidget {
  final String initialUsername;
  final ValidationService validationService = ValidationService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  ChangeNamePopup({required this.initialUsername});

  @override
  _ChangeNamePopupState createState() => _ChangeNamePopupState();
}

class _ChangeNamePopupState extends State<ChangeNamePopup> {
  late TextEditingController _nameController;
  bool _isValidUsername = true;
  String _userNameDiagnosis = "";
  Map get nameText => TranslationService.instance.text['USERNAME_MODIFICATION'];
  final ThemeService ts = ThemeService.instance;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUsername);
  }

  Future<void> _validateUsername(String username) async {
    String result = await widget.validationService.userNameDiagnosis(username);
    setState(() {
      _isValidUsername = result == "";
      _userNameDiagnosis = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ts.mainBackground.value,
      title: Text(
        nameText['TITLE'],
        style: TextStyle(color: ts.mainAccent.value),
      ),
      content: SizedBox(
        width: 300,
        height: 150,
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // Set the background color to white
                floatingLabelBehavior: FloatingLabelBehavior
                    .always, // Always show the label above the field
                labelStyle: TextStyle(color: ts.mainAccent.value),
                errorText:
                    !_isValidUsername ? nameText[_userNameDiagnosis] : null,
                border: OutlineInputBorder(),
              ),
              onChanged: (e) {
                _validateUsername(e);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(nameText['CANCEL']),
        ),
        TextButton(
          onPressed: () {
            if (_isValidUsername) {
              widget.loggedInUserService.setUsername(_nameController.text);
              Navigator.of(context).pop();
            }
          },
          child: Text(nameText['CONFIRM']),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
