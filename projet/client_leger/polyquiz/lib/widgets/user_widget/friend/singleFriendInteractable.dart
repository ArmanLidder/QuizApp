import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/widgets/user_widget/friend/smartFriendIcon.dart';

import '../../../services/theme_service.dart';
import '../smartAvatar.dart';
import 'AcceptOrRefuse.dart';

class SingleFriendInteractable extends StatelessWidget {
  final bool isPending;
  final String userId;
  SingleFriendInteractable({Key? key, required this.userId, this.isPending = false}) : super(key: key);
  final ThemeService _themeService = ThemeService.instance;

  Future<String> fetchUsername() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc['username'] ?? 'Unknown User';
    } catch (e) {
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Error loading user');
        } else {
          final username = snapshot.data!;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SmartAvatar(userId: userId,size: 35,),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        username,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black ),
                      ),
                    ),
                    IconButton(
                      icon: this.isPending? AcceptOrRefuse(targetUserId: userId): SmartFriendIcon(targetUserId: userId),
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5,)
            ],
          );
        }
      },
    );
  }
}