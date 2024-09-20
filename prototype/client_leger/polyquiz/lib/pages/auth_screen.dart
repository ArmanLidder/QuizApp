import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'token_manager.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final String baseUrl = 'http://ec2-35-183-137-76.ca-central-1.compute.amazonaws.com:8000/api/auth';
  // final String baseUrl = 'http://10.0.2.2:8000/api/auth'; // LocalServer 
  TokenSingleton t_storage = TokenSingleton.instance;

  bool _isRegistering = true;

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _registerUsernameController.text,
          'password': _registerPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showDialog('Succès', 'Le compte a été créé. Veuillez vous connecter.');
        setState(() {
          _isRegistering = true; // Switch to login form after registration
        });
      } else {
        final responseBody = jsonDecode(response.body);
        _showDialog("Erreur", '${responseBody['msg']}');
      }
    } catch (e) {
      _showDialog('Error', e.toString());
    }
  }

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _loginUsernameController.text,
          'password': _loginPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        t_storage.token = responseBody['token'];
        Navigator.pushReplacementNamed(context, '/chat');
      } else {
        final responseBody = jsonDecode(response.body);
        _showDialog('Erreur', '${responseBody['msg']}');
      }
    } catch (e) {
      _showDialog('Error', 'Login failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_isRegistering) ...[
                _buildLoginForm(),
              ] else ...[
                _buildRegisterForm(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Connecter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Connectez-vous à votre compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
        TextField(
          controller: _loginUsernameController,
          decoration: InputDecoration(labelText: 'Nom d\'utilisateur*'),
        ),
        TextField(
          controller: _loginPasswordController,
          decoration: InputDecoration(labelText: 'Mot de passe*'),
          obscureText: true,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('Se Connecter'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Pas de Compte?', style: TextStyle(color: Colors.black)),
            TextButton(
              onPressed: () => setState(() => _isRegistering = false),
              child: Text('S\'inscrire', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('S\'inscrire', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Créez un compte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
        TextField(
          controller: _registerUsernameController,
          decoration: InputDecoration(labelText: 'Nom d\'utilisateur*'),
        ),
        TextField(
          controller: _registerPasswordController,
          decoration: InputDecoration(labelText: 'Mot de passe*'),
          obscureText: true,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text('S\'inscrire'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Déjà un compte?', style: TextStyle(color: Colors.black)),
            TextButton(
              onPressed: () => setState(() => _isRegistering = true),
              child: Text('Se Connecter', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
