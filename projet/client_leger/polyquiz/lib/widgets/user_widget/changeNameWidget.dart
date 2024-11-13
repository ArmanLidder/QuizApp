import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUsername);
  }

  Future<void> _validateUsername(String username) async {
    bool result = await widget.validationService.isValidUsername(username);
    setState(() {
      _isValidUsername = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Change Name"),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'New Name',
          errorText: !_isValidUsername ? "username invalide" : null,
          border: OutlineInputBorder(),
        ),
        onChanged: (e) {
          _validateUsername(e);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_isValidUsername) {
              widget.loggedInUserService.setUsername(_nameController.text);
              Navigator.of(context).pop();
            }
          },
          child: Text("Soumettre"),
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
