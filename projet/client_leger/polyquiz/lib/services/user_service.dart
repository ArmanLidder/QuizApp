import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/user.dart';
import 'package:uuid/uuid.dart';

class UserService extends GetxController {
  final String collectionName = 'users';
  static UserService get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  /// Fetch a user by their ID
  Future<User?> getUserById(String id) async {
    final doc = await _db.collection(collectionName).doc(id).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    final user = User.fromJson(doc.data()!);
    return user;
  }
  Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No user found with the given email
      }

      // Assuming emails are unique, we can just take the first document
      final doc = querySnapshot.docs.first;
      final user = User.fromJson(doc.data()!);
      return user;
    } catch (e) {
      print('Failed to fetch user by email: $e');
      return null; // Handle the error appropriately
    }
  }
  Future<void> createUser({
    required String email,
    required String username,
  }) async {
    String uid = Uuid() as String;
    try {
      // Create a new user document in Firestore
      await _db.collection(collectionName).doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'avatar': '', // Default or empty avatar
        'friends': [],
        'currency': 0,
        'achievements': [],
        'level': 1,
        'prestige': 0,
        'isConnected': true,
        'stats': {
          'gamesPlayed': 0,
          'gamesWon': 0,
          'avgCorrectAnswers': 0,
          'avgGameTime': 0,
        },
        'loginHistory': [],
        'gameHistory': [],
        'friendRequests': [],
        'settings': {
          'theme': 'light',
          'language': 'en',
          'notificationsEnabled': true,
        },
      });
    } catch (e) {
      print('Failed to create user: $e');
      // Optionally handle the error further (e.g., logging or notifying the user)
    }
  }
}
