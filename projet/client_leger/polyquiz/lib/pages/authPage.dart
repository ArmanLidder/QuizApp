import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyquiz/constants/errorMessageTranslator.dart';
import 'package:polyquiz/services/userPageCustomisationService.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/constants/defaultAvatars.dart';
import 'package:polyquiz/constants/errorMessageTranslator.dart';

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
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _isValidUsername = true;
  bool _isValidEmail = true;
  bool _isValidPassword = true;
  String? _selectedAvatar;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await loggedInUserService.login(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e);
      if (e == "USER ALREADY CONNECTED") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Connexion échouée: ce compte est deja connecte')),
        );
      } else {
        print(e);
        FirebaseAuthException? error = e as FirebaseAuthException?;
        String? errorCode = error?.code;
        String? cleanErrorCode = firebaseAuthErrors[errorCode];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion échouée: $cleanErrorCode')),
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
        SnackBar(content: Text('Inscription réussie!')),
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
        SnackBar(content: Text('Inscription échouée: $cleanErrorCode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> defaultAvatars = constDefaultAvatars;
    return Scaffold(
      body: Center(
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
              Text(
                _isRegistering ? "Créer un compte" : "Connecter",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                _isRegistering
                    ? "Créez un compte pour commencer"
                    : "Connectez-vous à votre compte",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              if (_isRegistering)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    errorText: !_isValidUsername
                        ? "doit etre 1 a 10 charactères et chiffres"
                        : null,
                    prefixIcon: Icon(Icons.person),
                    labelText: "Nom d'utilisateur",
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
                      !_isValidEmail ? "doit etre une addresse valide" : null,
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Courriel*',
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
                  labelText: 'Mot de passe*',
                  errorText:
                      !_isValidPassword ? "doit avoir une longeur de 6" : null,
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
                  "Choisissez votre avatar",
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
                          CircleAvatar(
                            backgroundImage: NetworkImage(avatarUrl),
                            radius: 30,
                          ),
                          if (_selectedAvatar ==
                              avatarUrl) // Show checkmark if selected
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                /*SizedBox(height: 12),
                Text(
                  "Ou téléchargez votre propre avatar",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    //_selectedAvatar = imageStorageService.pickAndUploadImage();
                    // TODO: Implement file picker for custom avatar
                  },
                  child: Text("Choisir un fichier"),
                ),*/
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
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text(_isRegistering ? "S'inscrire" : 'Se connecter'),
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
                        ? "Déjà un compte? Se connecter"
                        : "Pas de compte? S'inscrire",
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
                    child: Text('Jouer hors-ligne')),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
