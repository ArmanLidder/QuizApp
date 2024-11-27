import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:polyquiz/models/user.dart';
import 'package:polyquiz/services/LanguageService.dart';
import 'package:polyquiz/services/translationService.dart';
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
  final TranslationService translationService = TranslationService.instance;
  late ThemeService themeService;
  Map get settingsText=> TranslationService.instance.text['SETTINGS'];
  late String _selectedTheme;
  List<String> listOfThemeNames = []; // Initialize with an empty list

  @override
  void initState() {
    super.initState();
    themeService = ThemeService.instance;
    userPageCustomisationService = UserPageCustomisationService.instance;
    _selectedTheme = themeService.themeName.value; // Assuming themeName is a property in your ThemeService

    // Trigger async initialization
    _initializeSettings();
  }

  void _initializeSettings() {
    _loadAvailableThemes();
  }

  Future<void> _loadAvailableThemes() async {
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
    return Obx(() => Container(
      color: themeService.mainBackground.value,
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(settingsText["TITLE"],
            style: TextStyle(fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeService.mainAccent.value),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settingsText["LANGUAGE"],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: themeService.mainAccent.value
                ),
              ),
              DropdownButton<String>(
                dropdownColor: themeService.mainBackground.value,
                value: translationService.currentLanguageAbbr,
                onChanged: (String? newValue) {
                  setState(() {
                    print(newValue!);
                    TranslationService.instance.currentLanguageAbbr =  newValue!;
                  });
                },
                items: <String>['Francais', 'English']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value == "Francais" ? "fr":"en",
                    child: Text(value, style: TextStyle(color: themeService.mainAccent.value),),
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
                settingsText["THEME"],
                style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeService.mainAccent.value,
                ),
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
    )));
  }
}
