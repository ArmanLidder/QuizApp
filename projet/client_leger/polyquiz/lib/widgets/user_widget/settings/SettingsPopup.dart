import 'package:flutter/material.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/theme_service.dart';

import 'Theme Option.dart';

class SettingsPopup extends StatefulWidget {
  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  late UserPageCustomisationService userPageCustomisationService;
  late ThemeService themeService;  // Declare the variable
  late String _selectedLanguage;
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    // Initialize themeService and _selectedTheme in initState
    themeService = ThemeService.instance;
    userPageCustomisationService = UserPageCustomisationService.instance;
    _selectedLanguage = 'Français';
    _selectedTheme = themeService.themeName.value; // Assuming themeName is a property in your ThemeService
  }
  @override
  Widget build(BuildContext context) {
    //print(userPage)
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
                items: <String>['Français', 'English']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 24.0),

          // Theme selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ThemeColorOption(
                    color: Colors.grey,
                    themeName:'default',
                  )
                  ,
                  SizedBox(width: 8),
                  ThemeColorOption(
                     color: Colors.black,
                    themeName:'dark',
                  ),
                  SizedBox(width: 8),
                  ThemeColorOption(
                    color: Colors.purple,
                    themeName:'disco',
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
