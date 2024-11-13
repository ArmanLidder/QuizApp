import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/widgets/user_widget/friend/smartFriendIcon.dart';

import '../smartAvatar.dart';

class SingleFriendInteractable extends StatelessWidget {
  final String userId;
  const SingleFriendInteractable({Key? key, required this.userId}) : super(key: key);

  Future<String> fetchUsername() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc['username'] ?? 'Unknown User';
    } catch (e) {
      print('Error fetching username: $e');
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
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Blue circle
                SmartAvatar(userId: userId,size: 35,),
                const SizedBox(width: 12),
                // Username text
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                // Person add icon
                IconButton(
                  icon: SmartFriendIcon(targetUserId: userId),
                  onPressed: () {
                    // Add onPressed functionality here
                    print('Add friend pressed for $username');
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}