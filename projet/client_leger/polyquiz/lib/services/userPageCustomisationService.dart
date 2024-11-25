import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import 'logged_in_user_service.dart';

class UserPageCustomisationService extends GetxService {
  // Singleton instance
  static UserPageCustomisationService get instance => Get.find();
  final LoggedInUserService loggedInUserService = LoggedInUserService.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> defaultAvatars() async {
    List<String> imageUrls = [];

    // Get all documents in the `defaultUsers` collection and add `source` fields to the list
    DocumentSnapshot defaultAvatarsDoc = await _firestore.collection('assets').doc('default_avatars').get();
    if (defaultAvatarsDoc.exists) {
      List<dynamic> avatarURLs = defaultAvatarsDoc.get('avatarURLS') ?? [];
      for (var url in avatarURLs) {
        if (url is String) {
          imageUrls.add(url);
        }
      }
    }
    return imageUrls;
  }

  Future<List<String>> purchasedAvatars(String userId) async {
    List<String> imageUrls = [];

    // Get the user-specific document in `storeAccount`
    DocumentSnapshot storeAccountSnapshot = await _firestore.collection('storeProfiles').doc(userId).get();
    if (storeAccountSnapshot.exists) {
      // Retrieve `itemsOwned` list from `storeAccount`
      List<dynamic> itemsOwned = storeAccountSnapshot.get('ownedItems') ?? [];

      // For each item in `itemsOwned`, get the document in `storeItems` and check `itemType`
      for (var itemId in itemsOwned) {
        DocumentSnapshot itemDoc = await _firestore.collection('storeItems').doc(itemId).get();
        if (itemDoc.exists && (itemDoc.get('itemType') == 'image' || itemDoc.get('itemType') == 'rewardImage')) {
          var source = itemDoc.get('source');
          if (source is String) {
            imageUrls.add(source);
          }
        }
      }
    }

    return imageUrls;
  }

  Future<List<String>> availableImages(String userId) async {
    List<String> imageUrls = [];

    // Fetch default avatars and purchased avatars and combine them
    imageUrls.addAll(await defaultAvatars());
    imageUrls.addAll(await purchasedAvatars(userId));
    return imageUrls;
  }
  Future<List<String>> purchasedThemes(String userId) async {
    List<String> themeNames = [];

    // Get the user-specific document in `storeAccount`
    DocumentSnapshot storeAccountSnapshot = await _firestore.collection('storeProfiles').doc(userId).get();
    if (storeAccountSnapshot.exists) {
      // Retrieve `itemsOwned` list from `storeAccount`
      List<dynamic> itemsOwned = storeAccountSnapshot.get('ownedItems') ?? [];

      // For each item in `itemsOwned`, get the document in `storeItems` and check `itemType`
      for (var itemId in itemsOwned) {
        DocumentSnapshot itemDoc = await _firestore.collection('storeItems').doc(itemId).get();
        if (itemDoc.exists && itemDoc.get('itemType') == 'theme' || itemDoc.get('itemType') == 'rewardTheme') {
          var name = itemDoc.get('name');
          if (name is String) {
            themeNames.add(name);
          }
        }
      }
    }
    return themeNames;
  }
  Future<List<String>> availableThemes() async {
    String userId = loggedInUserService.getUid()!;
    List<String> themeNames = await this.purchasedThemes(userId);
    return ["dark", "light", ...themeNames];
  }
}