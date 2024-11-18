import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';
import '../../../services/LanguageService.dart';

class UserIdsRow extends StatefulWidget {
  const UserIdsRow({Key? key}) : super(key: key);

  @override
  _UserIdsRowState createState() => _UserIdsRowState();
}

class _UserIdsRowState extends State<UserIdsRow> {
  String filterText = ''; // Text input for filtering
  final LanguageService ls = LanguageService.instance;

  // Filters the list of users based on the entered text.
  List<QueryDocumentSnapshot> _filterUsers(
      List<QueryDocumentSnapshot> users, String filter) {
    return users
        .where((doc) {
      final username = doc['username'] as String? ?? '';
      return username.toLowerCase().contains(filter.toLowerCase());
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text Field for filtering usernames
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                filterText = value;
              });
            },
            decoration: InputDecoration(
              labelText: ls.filterByUsernameText,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // StreamBuilder to listen to the users collection
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              // Filter users based on the entered text
              final filteredUsers =
              _filterUsers(snapshot.data!.docs, filterText);

              // Build the widgets for each user
              return ListView(
                children: filteredUsers.map((doc) {
                  final uid = doc['uid'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleFriendInteractable(userId: uid),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
