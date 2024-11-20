import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyquiz/constants/errorMessageTranslator.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/constants/defaultAvatars.dart';
import 'package:polyquiz/constants/errorMessageTranslator.dart';

import '../services/translationService.dart';
import '../services/userInfoValidation.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService userService = UserService.instance;
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();
  final UserPageCustomisationService userPageCustomisationService =
      UserPageCustomisationService.instance;
  final ValidationService validationService = ValidationService.instance;
  final TranslationService translationService = TranslationService.instance;

  Map get text => translationService.text;
  Map get registerPageText => this.text['REGISTER_PAGE'];
  Map get loginPageText => this.text['LOGIN_PAGE'];

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _isValidUsername = true;
  bool _isValidEmail = true;
  bool _isValidPassword = true;
  String? _selectedAvatar;
  Widget languageDropdown() {
    _selectedAvatar = constDefaultAvatars[0];

    return DropdownButton<String>(
      value: translationService.currentLanguageAbbr,
      onChanged: (String? newLanguage) {
        if (newLanguage != null) {
          setState(() {
            translationService.currentLanguageAbbr = newLanguage; // Update language in TranslationService
            // Re-fetch text values after changing the language
            _refreshText();
          });
        }
      },
      items: [
        DropdownMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: 'fr',
          child: Text('Français'),
        ),
      ],
    );
  }

// Helper function to refresh text values after language change
  void _refreshText() {
    setState(() {
      // Re-fetch translation text after setting the language
      // This triggers the UI to update
    });
  }
  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await loggedInUserService.login(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loginPageText['SUCCESS_LOGIN_POPUP'])),
      );
      translationService.currentLanguage = loggedInUserService.user!.settings.language;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);
      if (e == "USER ALREADY CONNECTED") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loginPageText['USER_ALREADY_CONNECTED'])),
        );
      } else {
        print(e);
        FirebaseAuthException? error = e as FirebaseAuthException?;
        String? errorCode = error?.code;
        String? cleanErrorCode = firebaseAuthErrors[errorCode];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginPageText[cleanErrorCode])),
        );
      }
    }
  }

  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(registerPageText['SUCCESS_REGISTER_POPUP'])),
      );

      await userService.createUser(
        _selectedAvatar!,
        _emailController.text,
        _usernameController.text,
      );
      setState(() {
        _isRegistering = false;
      });
      _login();
    } catch (e) {
      FirebaseAuthException? error = e as FirebaseAuthException?;
      String? errorCode = error?.code;
      String? cleanErrorCode = firebaseAuthErrors[errorCode];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(registerPageText[cleanErrorCode])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> defaultAvatars = constDefaultAvatars;
    return Scaffold(
      body: SingleChildScrollView(
          child:Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              languageDropdown(),
              Text(
                _isRegistering ? registerPageText['TITLE'] : loginPageText['TITLE'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _isRegistering
                    ? registerPageText['TITLE']
                    : loginPageText['SUBTITLE'],
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              if (_isRegistering)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    errorText: !_isValidUsername
                        ? registerPageText['USERNAME_INVALID']
                        : null,
                    prefixIcon: Icon(Icons.person),
                    labelText: registerPageText['USERNAME_LABEL'],
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (e) async {
                    bool result = await validationService.isValidUsername(e);
                    setState(() {
                      _isValidUsername = result;
                    });
                    print(_isValidUsername); // You can print the result here
                  },
                ),
              if (_isRegistering) SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  errorText:
                  !_isValidEmail ? registerPageText['EMAIL_INVALID'] : null,
                  prefixIcon: Icon(Icons.email),
                  labelText: registerPageText['EMAIL_LABEL'],
                  border: OutlineInputBorder(),
                ),
                onChanged: (e) async {
                  bool result = await validationService.isValidAddress(e);
                  setState(() {
                    _isValidEmail = result;
                  });
                  print(_isValidEmail); // You can print the result here
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: registerPageText['PASSWORD_LABEL'],
                  errorText:
                  !_isValidPassword ? registerPageText['PASSWORD_MIN_LENGTH'] : null,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (e) async {
                  bool result = await validationService.isValidPassword(e);
                  setState(() {
                    _isValidPassword = result;
                  });
                },
              ),
              if (_isRegistering) ...[
                SizedBox(height: 24),
                Text(
                  this.text['AVATAR_MODIFICATION']['CHOOSE_AVATAR'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: defaultAvatars.map((avatarUrl) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatarUrl;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedAvatar == avatarUrl
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3, // Border thickness
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(avatarUrl),
                              radius: 30,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isRegistering &&
                      _isValidUsername &&
                      _isValidEmail &&
                      _isValidPassword)
                      ? _register
                      : (_isValidUsername && _isValidEmail && _isValidPassword)
                      ? _login
                      : null, // Disable the button if conditions are not met
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isRegistering ? loginPageText['REGISTER_LINK'] : loginPageText['SUBMIT_BUTTON']),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                      _isValidUsername = true;
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? registerPageText['ALREADY_HAVE_ACCOUNT'] + registerPageText['LOGIN_LINK']
                        : loginPageText['NO_ACCOUNT'] + loginPageText['REGISTER_LINK'],
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/offline');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.black,
                    ),
                    child: Text(loginPageText["OFFLINE_PLAY"])),
              )
            ],
          ),
        ),
      )));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
