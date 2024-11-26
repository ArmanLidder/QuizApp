import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/translationService.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';
import '../../../services/LanguageService.dart';
import '../../../services/friendService.dart';

class UserIdsRow extends StatefulWidget {
  const UserIdsRow({Key? key}) : super(key: key);

  @override
  _UserIdsRowState createState() => _UserIdsRowState();
}

class _UserIdsRowState extends State<UserIdsRow> {
  String filterText = ''; // Text input for filtering
  final LanguageService ls = LanguageService.instance;
 final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  Future<List<QueryDocumentSnapshot>> _filterUsers(List<QueryDocumentSnapshot> users, String filter) async {
    List<QueryDocumentSnapshot> filteredUsers = [];
    for (var doc in users) {
      final username = doc['username'] as String? ?? '';
      final userId = doc['uid'] as String? ?? '';
      final loggedInUid = loggedInUserService.getUid();
      if (username.toLowerCase().contains(filter.toLowerCase()) &&
          userId != loggedInUserService.getUid()) {
        bool isAlreadyFriends = await FriendService.instance.friendshipStatus(loggedInUid!, userId) == "friends";
        if (!isAlreadyFriends) {
          filteredUsers.add(doc);
        }
      }
    }
    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                filterText = value;
              });
            },
            decoration: InputDecoration(
              labelText: TranslationService.instance.text["USER_SEARCH"]["PLACEHOLDER"],
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _filterUsers(snapshot.data!.docs, filterText),
                builder: (context, filteredSnapshot) {
                  if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (filteredSnapshot.hasError) {
                    return Center(child: Text('Error: ${filteredSnapshot.error}'));
                  }
                  final filteredUsers = filteredSnapshot.data ?? [];
                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
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
              );
            },
          ),
        ),
      ],
    );
  }
}
