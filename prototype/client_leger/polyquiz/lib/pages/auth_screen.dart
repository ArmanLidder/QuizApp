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
