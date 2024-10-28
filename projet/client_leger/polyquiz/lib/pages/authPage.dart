import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:polyquiz/services/imageStorageService.dart';
import 'package:polyquiz/services/user_service.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService userService = UserService();
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;
  final ImageStorageService imageStorageService = ImageStorageService();

  bool _isRegistering = false;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection réussie!')),
      );
      await this.loggedInUserService.setUserByEmail(_emailController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection échouée: $e')),
      );
    }
  }

  Future<void> _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Here, you could save the username to a user profile or database.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription réussie!')),
      );

      this.userService.createUser(
          email: _emailController.text,
          username: _usernameController.text);
      setState(() {
        _isRegistering =
            false; // Return to login mode after successful registration.
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription échouée: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? "S'enregistrer" : 'Se connecter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRegistering)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "nom d'utilisateur",
                  border: OutlineInputBorder(),
                ),
              ),
            if (_isRegistering) SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Adresse mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isRegistering ? _register : _login,
              child: Text(_isRegistering ? "S'enregistrer" : 'Se connecter'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                });
              },
              child: Text(_isRegistering
                  ? 'Tu as déja un compte? connecte toi!'
                  : "tu n'as pas de compte? connecte-toi!"),
            ),

          ],
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
