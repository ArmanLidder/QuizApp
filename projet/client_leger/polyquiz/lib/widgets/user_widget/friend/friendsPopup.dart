import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';

class UserIdsRow extends StatefulWidget {
  const UserIdsRow({Key? key}) : super(key: key);

  @override
  _UserIdsRowState createState() => _UserIdsRowState();
}

class _UserIdsRowState extends State<UserIdsRow> {
  List<String>? cachedUserIds;

  Future<List<String>> fetchUserIds() async {
    // If user IDs are already cached, return them directly
    if (cachedUserIds != null) return cachedUserIds!;

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      cachedUserIds = snapshot.docs.map((doc) => doc['uid'].toString()).toList();
      return cachedUserIds!;
    } catch (e) {
      print('Error fetching user IDs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchUserIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading user IDs');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No user IDs found');
        } else {
          final userIds = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: userIds.map((uid) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleFriendInteractable(userId: uid),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
