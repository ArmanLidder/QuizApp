import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class FriendService extends GetxService {
  static FriendService get instance => Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> createFriendRequest(String currentUserId, String targetUserId) async {
    try {
      final targetUserDoc = await _firestore.collection('users').doc(targetUserId).get();
      final targetUserFriendRequests = List<Map<String, dynamic>>.from(targetUserDoc.data()?['friendRequests'] ?? []);

      final reverseRequestExists = targetUserFriendRequests.any((request) =>
      request['fromUserId'] == targetUserId && request['toUserId'] == currentUserId);

      if (reverseRequestExists) {
        await acceptFriendRequest(targetUserId, currentUserId);
        return;
      } else {
        await _firestore.collection('users').doc(targetUserId).update({
          'friendRequests': FieldValue.arrayUnion([
            {'fromUserId': currentUserId, 'toUserId': targetUserId}
          ]),
        });
        await _firestore.collection('users').doc(currentUserId).update({
          'friendRequests': FieldValue.arrayUnion([
            {'fromUserId': currentUserId, 'toUserId': targetUserId}
          ]),
        });
      }
    } catch (e) {
      print('Error creating friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String currentUserId, String requesterId) async {
    try {
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
      List<dynamic> friendsList = currentUserDoc['friends'] ?? [];
      List<dynamic> friendRequestsList = currentUserDoc['friendRequests'] ?? [];

      if (friendsList.contains(targetUserId)) {
        return 'friends';
      } else if (friendRequestsList.any((request) => request['fromUserId'] == targetUserId)) {
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
}
