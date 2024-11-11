import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyquiz/services/UserPageCustomisationService.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/constants/defaultAvatars.dart';

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
  final UserPageCustomisationService userPageCustomisationService = UserPageCustomisationService.instance;

  bool _isRegistering = false;
  bool _obscurePassword = true;
  String? _selectedAvatar;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion réussie!')),
      );
      await loggedInUserService.setUserByEmail(_emailController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connexion échouée: $e')),
      );
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription échouée: $e')),
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
                _isRegistering ? "Créez un compte pour commencer" : "Connectez-vous à votre compte",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              if (_isRegistering)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: "Nom d'utilisateur",
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_isRegistering) SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Courriel*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Mot de passe*',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
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
                          if (_selectedAvatar == avatarUrl) // Show checkmark if selected
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
                  onPressed: _isRegistering ? _register : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Colors.blue[300],
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
