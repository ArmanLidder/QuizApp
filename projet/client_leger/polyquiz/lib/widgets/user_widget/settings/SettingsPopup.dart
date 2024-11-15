import 'package:flutter/material.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/theme_service.dart';
import '../../../constants/themesNamesToColorArray.dart';
import 'Theme Option.dart';

class SettingsPopup extends StatefulWidget {
  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  late UserPageCustomisationService userPageCustomisationService;
  final LanguageService languageService = LanguageService.instance;

  late ThemeService themeService;
  late String _selectedLanguage;
  late String _selectedTheme;
  List<String> listOfThemeNames = []; // Initialize with an empty list

  @override
  Future<void> initState() async {
    super.initState();
    themeService = ThemeService.instance;
    userPageCustomisationService = UserPageCustomisationService.instance;
    _selectedLanguage = languageService.languageAbr.value;
    _selectedTheme = themeService.themeName.value; // Assuming themeName is a property in your ThemeService

    // Load the list of themes asynchronously
    await _loadAvailableThemes();
  }

  Future<void> _loadAvailableThemes() async {
    await languageService.loadLanguage();
    _selectedLanguage = languageService.languageAbr.value;
    List<String> themes = await userPageCustomisationService.availableThemes();
    setState(() {
      listOfThemeNames = themes;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Generate the theme options dynamically
    final List<Widget> themeOptions = listOfThemeNames
        .map((themeName) => Row(
      children: [
        ThemeColorOption(
          color: themeColors[themeName]![0], // Placeholder color
          themeName: themeName,
        ),
        SizedBox(width: 8),
      ],
    ))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Language',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: abrToName[_selectedLanguage],
                onChanged: (String? newValue) {
                  setState(() {
                    LanguageService.instance.setLanguage(newValue!);
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
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: themeOptions),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
