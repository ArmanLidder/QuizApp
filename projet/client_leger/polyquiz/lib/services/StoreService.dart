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
  final _purchaseTrigger = 0.obs;
  int get purchaseTrigger => _purchaseTrigger.value;

  void _createStoreProfile(String userId) async {
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
      DocumentSnapshot doc =
          await _firestore.collection('storeProfiles').doc(userId).get();

      if (!doc.exists) {
        this._createStoreProfile(userId);
      }
    } catch (e) {
      print("Error checking or creating store profile: $e");
    }
  }

  Future<void> addToOwned(String userId, String itemId) async {
    try {
      await this.createStoreProfileIfNeeded(userId);
      DocumentReference userDocRef =
          _firestore.collection('storeProfiles').doc(userId);
      await userDocRef.update({
        'ownedItems': FieldValue.arrayUnion([itemId]),
      });
    } catch (e) {
      print("Error adding item to owned items: $e");
    }
  }

  Future<bool> isOwned(String userId, String itemId) async {
    try {
      // Reference to the user's document
      DocumentReference userDocRef =
          _firestore.collection('storeProfiles').doc(userId);
      // Fetch the user's document
      DocumentSnapshot userDoc = await userDocRef.get();

      // Check if the document exists
      if (userDoc.exists) {
        // Retrieve the ownedItems field
        Map<String, dynamic> itemData = userDoc.data() as Map<String, dynamic>;

        List<dynamic> ownedItems = itemData['ownedItems'] ?? [];
        // Check if the itemId exists in the ownedItems
        return ownedItems.contains(itemId);
      } else {
        // If the user document does not exist, return false
        return false;
      }
    } catch (e) {
      print("Error checking if item is owned: $e");
      return false; // Return false in case of error
    }
  }

  buy(String userId, String itemId) async {
    User? user = await userService.getUserById(userId);
    num availableMoney = user?.currency ?? 0;
    DocumentSnapshot itemDoc =
        await _firestore.collection('storeItems').doc(itemId).get();

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
    _purchaseTrigger.value++; // Increment to trigger observers
  }

  Future<Map<String, List<Map<String, dynamic>>>> browseStoreItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('storeItems').get();
      List<Map<String, dynamic>> themes = [];
      List<Map<String, dynamic>> images = [];
      List<Map<String, dynamic>> rewardImages = [];
      List<Map<String, dynamic>> rewardThemes = [];
      List<Map<String, dynamic>> rewardCash = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        String itemType = item['itemType'] ?? '';
        item['id'] = doc.id;

        if (itemType == 'theme') {
          themes.add(item);
        } else if (itemType == 'image') {
          images.add(item);
        } else if (itemType == 'rewardImage') {
          rewardImages.add(item);
      }else if (itemType == 'rewardTheme') {
          rewardThemes.add(item);
        }
        else if (itemType == "rewardCurrency"){
          rewardCash.add(item);
        }
      }

      return {
        'themes': themes,
        'images': images,
        'rewardImages': rewardImages,
        'rewardThemes': rewardThemes,
        'rewardCurrency': rewardCash,
      };
    } catch (e) {
      print("Error browsing store items: $e");
      return {
        'themes': [],
        'images': [],
      };
    }
  }
}
