import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class FriendService extends GetxService {
  static FriendService get instance => Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive lists for friends and friend requests
  RxList<String> friends = <String>[].obs;
  RxList<String> friendRequests = <String>[].obs;

  manuallyLoadFriends() {
    // Manually initialize the lists when the service is instantiated
    print("loaded");
    _loadFriends();
    _loadPendingRequests();
  }

  Future<void> _loadFriends() async {
    String? userId = LoggedInUserService.instance.getUid();
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      List<dynamic> friendsList = userDoc['friends'] ?? [];
      friends.assignAll(friendsList as List<String>);
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  Future<void> _loadPendingRequests() async {
    String? currentUserId = LoggedInUserService.instance.getUid();
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
      List<dynamic> friendRequestsList = userDoc['friendRequests'] ?? [];

      // Map the requests to user IDs, excluding the current user's ID
      List<String> pendingRequests = friendRequestsList.map<String>((request) {
        if (request is Map<String, dynamic>) {
          String userId;
          if (request['fromUserId'] == currentUserId) {
            userId = request['toUserId'] as String;
          } else {
            userId = request['fromUserId'] as String;
          }
          return userId;
        }
        return '';
      }).where((id) => id.isNotEmpty).toList();

      friendRequests.assignAll(pendingRequests);
    } catch (e) {
      print('Error loading pending requests: $e');
    }
  }

  // Function to create a friend request
  Future<void> createFriendRequest(String currentUserId, String targetUserId) async {
    try {
      // Retrieve the target user's friend requests to check for a reverse request
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

    friendRequests.add(targetUserId);
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

    friendRequests.remove(requesterId);
    friends.add(requesterId);
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

    friendRequests.remove(requesterId);
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

    friends.remove(friendId);
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

  Future<List<String>> getFriendList() async {
    return friends;
  }

  Future<List<String>> getPendingList() async {
    return friendRequests;
  }
}
