import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import to use json.encode

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _registerUsernameController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _loginUsernameController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final String baseUrl = 'http://10.0.2.2:8000/api/auth';
  bool _isRegistering = true; // Flag to toggle between register and login

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

void _register() async {
  print('Registering...');
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
      _showDialog('Success', 'Registration successful! Please log in.');
      setState(() {
        _isRegistering = false; // Switch to login form after successful registration
      });
    } else {
      final responseBody = jsonDecode(response.body);
      _showDialog('Error', 'Registration failed: ${responseBody['error'] ?? 'Unknown error'}');
    }
  } catch (e) {
    print('Register error: $e');
    _showDialog('Error', 'Registration failed. Please try again.');
  }
}

void _login() async {
  print('Logging in...');
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
      Navigator.pushReplacementNamed(context, '/chat');
    } else {
      final responseBody = jsonDecode(response.body);
      _showDialog('Error', 'Login failed: ${responseBody['error'] ?? 'Invalid username or password'}');
    }
  } catch (e) {
    print('Login error: $e');
    _showDialog('Error', 'Login failed. Please try again.');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authentication')),
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_isRegistering) ...[
                Text('Register', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _registerUsernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _registerPasswordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: _register, child: Text('Register')),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = false),
                  child: Text('Already have an account? Login'),
                ),
              ] else ...[
                Text('Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _loginUsernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _loginPasswordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: _login, child: Text('Login')),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = true),
                  child: Text('Don\'t have an account? Register'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
