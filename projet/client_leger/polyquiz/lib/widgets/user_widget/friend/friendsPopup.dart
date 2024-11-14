import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:polyquiz/widgets/user_widget/friend/singleFriendInteractable.dart';

class UserIdsRow extends StatefulWidget {
  const UserIdsRow({Key? key}) : super(key: key);

  @override
  _UserIdsRowState createState() => _UserIdsRowState();
}

class _UserIdsRowState extends State<UserIdsRow> {
  List<Map<String, dynamic>>? cachedUserWidgets;  // Cache of username and corresponding widget
  String filterText = '';  // Text input for filtering

  // Fetch user data and create widgets. This should only be called once on initial load.
  Future<List<Map<String, dynamic>>> fetchUserWidgets() async {
    // If widgets are already cached, return them directly
    if (cachedUserWidgets != null) return cachedUserWidgets!;

    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> userWidgets = [];

      for (var doc in snapshot.docs) {
        String username = doc['username'].toString();
        String uid = doc['uid'].toString();

        // Create a SingleFriendInteractable widget for each user
        var widget = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleFriendInteractable(userId: uid),
        );

        // Store username and widget together in the cache
        userWidgets.add({
          'username': username,
          'widget': widget,
        });
      }

      cachedUserWidgets = userWidgets;
      return cachedUserWidgets!;
    } catch (e) {
      print('Error fetching user IDs: $e');
      return [];
    }
  }

  // Filter widgets based on the entered filter text.
  List<Map<String, dynamic>> _filterUserWidgets(String filter) {
    if (cachedUserWidgets == null) return [];

    return cachedUserWidgets!
        .where((entry) {
      final username = entry['username'] as String;
      return username.toLowerCase().contains(filter.toLowerCase());
    })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Only fetch the data once when the widget is first initialized
    fetchUserWidgets();
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
              labelText: 'Filter by username',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        // Display the cached widgets, with a scrollable list
        cachedUserWidgets == null
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator while data is fetched
            : Expanded( // Wrap the list with an Expanded widget to allow scrolling
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: _filterUserWidgets(filterText).map((entry) {
                return entry['widget'] as Widget;
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
