import 'package:flutter/material.dart';
import 'package:polyquiz/services/global_navigation_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  GlobalNavigationService globalNavigationService = GlobalNavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PolyQuiz'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(53, 121, 246, 1),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to the '/quizz' route
              globalNavigationService.navigateTo('/quizz');
              //Navigator.pushNamed(context, '/quizz');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromRGBO(53, 121, 246, 1), // Button color
            ),
            child: const Text(
              'Create a room',
              style: TextStyle(color: Colors.white), // Text color
            ),
          ),
          const SizedBox(height: 20), // Add some space between the buttons
          ElevatedButton(
            onPressed: () {
              // Navigate to the '/join' route
              globalNavigationService.navigateTo('/join');
              //Navigator.pushNamed(context, '/join');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromRGBO(53, 121, 246, 1), // Button color
            ),
            child: const Text(
              'Join a room',
              style: TextStyle(color: Colors.white), // Text color
            ),
          ),
        ],
      ),
    );
  }
}
