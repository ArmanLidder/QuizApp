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

      if (false) {
        await acceptFriendRequest(targetUserId, currentUserId);
        return;
      } else {
        await _firestore.collection('users').doc(targetUserId).update({
          'friendRequests': FieldValue.arrayUnion([
            {'fromUserId': currentUserId, 'toUserId': targetUserId}
          ]),
        });

      }
    } catch (e) {
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
      });
    } catch (e) {
    }
  }

  Future<void> refuseFriendRequest(String currentUserId, String requesterId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([{'fromUserId': requesterId, 'toUserId': currentUserId}]),
      });
    } catch (e) {
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
    }
  }

  Future<String> friendshipStatus( String targetUserId) async {
    try {
      List<String> friendsList = LoggedInUserService.instance.friends.value;
      List<String> friendRequestsList = LoggedInUserService.instance.friendRequests.value;

      DocumentSnapshot targetUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(targetUserId).get();
      List<Map<String, dynamic>> targetUserFriendRequests =
      List<Map<String, dynamic>>.from(targetUserDoc['friendRequests'] ?? []);

      if (friendsList.contains(targetUserId)) {
        return 'friends';
      } else if (friendRequestsList.any((request) => request == targetUserId)) {
        return 'receivedPending';
      }else if (targetUserFriendRequests.any((request) => request['fromUserId'] == LoggedInUserService.instance.getUid()!)) {
        return 'sentPending';
      }
      else {
          return 'notFriends';
        }

    } catch (e) {
      return 'error';
    }
  }
}
