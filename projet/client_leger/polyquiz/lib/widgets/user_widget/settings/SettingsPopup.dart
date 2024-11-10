import 'package:flutter/material.dart';

import 'Theme Option.dart';

class SettingsPopup extends StatefulWidget {
  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  String _selectedLanguage = 'Français';
  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      setState(() {
                        _selectedColor = Colors.grey;
                      });
                    }, color: Colors.grey,
                    label:'normal',
                    isSelected: _selectedColor == Colors.grey,),
                  SizedBox(width: 8),
                  ThemeColorOption(
                    onTap: () {
                      setState(() {
                        _selectedColor = Colors.black;
                      });
                    }, color: Colors.black,
                    label:'dark mode',
                    isSelected: _selectedColor == Colors.black,),

                  SizedBox(width: 8),
                  ThemeColorOption(
                    onTap: () {
                      setState(() {
                        _selectedColor = Colors.purple;
                      });
                    }, color: Colors.purple,
                  label:'disco',
                  isSelected: _selectedColor == Colors.purple,),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
