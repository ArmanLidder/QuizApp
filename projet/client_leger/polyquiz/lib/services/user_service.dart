import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/user.dart';

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

  Future<String> getUserNameById(String id) async {
    User? user = await this.getUserById(id);
    return user?.username ?? "";
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final user = User.fromJson(doc.data()!);
      return user;
    } catch (e) {
      print('Failed to fetch user by email: $e');
      return null; // Handle the error appropriately
    }
  }

  Future<void> createUser(String email, String username) async {
    try {
      DocumentReference docRef = _db.collection(collectionName).doc();

      await docRef.set({
        'email': email,
        'username': username,
        'uid': docRef.id,
        'avatar':
            'https://firebasestorage.googleapis.com/v0/b/polyquiz-app.appspot.com/o/default_avatars%2Fdefault_1.png?alt=media&token=fb150a6e-29e8-4469-b24c-e05a338ebc58',
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

      print('User created');
    } catch (e) {
      print('Failed to create user: $e');
    }
  }

  Future<void> updateUserAvatar({
    required String id,
    required String newAvatarUrl,
  }) async {
    try {
      await _db.collection(collectionName).doc(id).update({
        'avatar': newAvatarUrl,
      });
      print('Avatar updated successfully');
    } catch (e) {
      print('Failed to update avatar: $e');
    }
  }
}
