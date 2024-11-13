import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class FriendService {
  static FriendService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createFriendRequest(String currentUserId, String targetUserId) async {
    try {
      // Add a request to the target user's 'friendRequests' with both fromUserId and toUserId
      await _firestore.collection('users').doc(targetUserId).update({
        'friendRequests': FieldValue.arrayUnion([
          {'fromUserId': currentUserId, 'toUserId': targetUserId}
        ]),
      });

      // Add an entry to the sender's 'friendRequests' with both fromUserId and toUserId
      await _firestore.collection('users').doc(currentUserId).update({
        'friendRequests': FieldValue.arrayUnion([
          {'fromUserId': currentUserId, 'toUserId': targetUserId}
        ]),
      });
    } catch (e) {
      print('Error creating friend request: $e');
    }
  }
  Future<void> acceptFriendRequest(String currentUserId, String requesterId) async {
    try {
      // Accept the request by adding each user to the other's 'friends' list
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([{'fromUserId': requesterId, 'toUserId': currentUserId}]),
      });
      await _firestore.collection('users').doc(requesterId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
        'friendRequests': FieldValue.arrayRemove([{'fromUserId': requesterId, 'toUserId': currentUserId}]),
      });
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> refuseFriendRequest(String currentUserId, String requesterId) async {
    try {
      // Remove the friend request without adding to friends
      await _firestore.collection('users').doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([{'fromUserId': requesterId, 'toUserId': currentUserId}]),
      });
      await _firestore.collection('users').doc(requesterId).update({
        'friendRequests': FieldValue.arrayRemove([{'fromUserId': requesterId, 'toUserId': currentUserId}]),
      });
    } catch (e) {
      print('Error refusing friend request: $e');
    }
  }
  Future<void> deleteFriendship(String currentUserId, String friendId) async {
    try {
      // Remove each user from the other's 'friends' list
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
      } else if (friendRequests.any((request) => request['fromUserId'] == targetUserId)) {
        return 'receivedPending';
      } else {
        DocumentSnapshot targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
        List<dynamic> targetFriendRequests = targetUserDoc['friendRequests'] ?? [];
        if (targetFriendRequests.any((request) => request['fromUserId'] == currentUserId)) {
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

  Future<List<String>> getFriendList() async {
    String? userId =  LoggedInUserService.instance.getUid();
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      List<dynamic> friends = userDoc['friends'] ?? [];
      return friends.cast<String>();  // Cast to List<String> if 'friends' is a list of user IDs
    } catch (e) {
      print('Error getting friend list: $e');
      return [];
    }
  }

  Future<List<String>> getPendingList() async {
    String? currenUserId = LoggedInUserService.instance.getUid();
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currenUserId).get();
      List<dynamic> friendRequests = userDoc['friendRequests'] ?? [];

      //retourne le id qui n<est pas le sien -Maxime Pageot
        List<String> pendingRequests = friendRequests.map<String>((request) {
        if (request is Map<String, dynamic>) {
          String userId;
          if (request['fromUserId'] == currenUserId) {
            userId = request['toUserId'] as String;
          } else {
            userId = request['fromUserId'] as String;
          }
          return userId;
        }
        return '';
      }).where((id) => id.isNotEmpty).toList();

      return pendingRequests;
    } catch (e) {
      print('Error getting pending friend requests: $e');
      return [];
    }
  }

}
