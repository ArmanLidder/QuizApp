import 'package:cloud_firestore/cloud_firestore.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFriendRequest(String currentUserId, String targetUserId) async {
    try {
      await _firestore.collection('users').doc(targetUserId).update({
        'friendRequests': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print('Error creating friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String currentUserId, String requesterId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });
      await _firestore.collection('users').doc(requesterId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> refuseFriendRequest(String currentUserId, String requesterId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });
    } catch (e) {
      print('Error refusing friend request: $e');
    }
  }

  Future<void> deleteFriendship(String currentUserId, String friendId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayRemove([friendId]),
      });
      await _firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayRemove([currentUserId]),
      });
    } catch (e) {
      print('Error deleting friendship: $e');
    }
  }

  Future<String> friendshipStatus(String currentUserId, String targetUserId) async {
    try {
      DocumentSnapshot currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      List<dynamic> friends = currentUserDoc['friends'] ?? [];
      List<dynamic> friendRequests = currentUserDoc['friendRequests'] ?? [];

      if (friends.contains(targetUserId)) {
        return 'friends';
      } else if (friendRequests.contains(targetUserId)) {
        return 'receivedPending';
      } else {
        DocumentSnapshot targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
        List<dynamic> targetFriendRequests = targetUserDoc['friendRequests'] ?? [];

        if (targetFriendRequests.contains(currentUserId)) {
          return 'sentPending';
        } else {
          return 'notFriends';
        }
      }
    } catch (e) {
      print('Error checking friendship status: $e');
      return 'error';
    }
  }
}
