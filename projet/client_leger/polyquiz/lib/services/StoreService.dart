
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';
import '../models/user.dart';


class StoreService extends GetxController {
  static StoreService get instance => Get.find();
  final UserService userService = UserService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void createStoreProfile(String userId) async {
    try {
      await _firestore.collection('storeProfiles').doc(userId).set({
        'ownedItems': <String>[], // Empty list of owned items
      });
    } catch (e) {
      print("Error creating store profile: $e");
    }
  }

  Future<void> createStoreProfileIfNeeded(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('storeProfiles').doc(
          userId).get();

      if (!doc.exists) {
        // If the document does not exist, create the store profile
        this.createStoreProfile(userId);
      }
    } catch (e) {
      print("Error checking or creating store profile: $e");
    }
  }

  Future<void> addToOwned(String userId, String itemId) async {
    try {
      await this.createStoreProfileIfNeeded(userId);
      DocumentReference userDocRef = _firestore.collection('storeProfiles').doc(
          userId);
      await userDocRef.update({
        'ownedItems': FieldValue.arrayUnion([itemId]),
      });
    } catch (e) {
      print("Error adding item to owned items: $e");
    }
  }

  buy(String userId, String itemId) async {
    User? user = await userService.getUserById(userId);
    num availableMoney = user?.currency ?? 0;
    DocumentSnapshot itemDoc = await _firestore.collection('storeItems').doc(
        itemId).get();

    if (!itemDoc.exists) {
      print("item doesnt exist");
      return;
    }

      // Extract the item cost
      Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
      num itemCost = itemData['cost'] ?? 0;
    if (availableMoney < itemCost) {
      print("not enough money");
      return;
    }
      await _firestore.collection('users').doc(userId).update({
        'currency': availableMoney - itemCost,
      });
     await addToOwned(userId, itemId);
    }
}
