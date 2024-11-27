import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:polyquiz/services/user_service.dart';


class StoreService extends GetxController {
  static StoreService get instance => Get.find();
  final UserService userService = UserService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _purchaseTrigger = 0.obs;

  int get purchaseTrigger => _purchaseTrigger.value;
  final Rx<List<String>> _itemsOwned = Rx([]);
  final Rx<Map<String, List<Map<String, dynamic>>>> _storeItems = Rx({
    'themes': [],
    'images': [],
    'rewardImages': [],
    'rewardThemes': [],
    'rewardCurrency': [],
  });
  Map<String, List<Map<String, dynamic>>> get storeItems => _storeItems.value;


  void setup(){
    listenToStoreItems();
    listenToOwnedItems();
    loadInitialStoreItems();
    loadInitialOwnedItems();
  }

  void loadInitialStoreItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('storeItems').get();
      Map<String, List<Map<String, dynamic>>> categorizedItems = {
        'themes': [],
        'images': [],
        'rewardImages': [],
        'rewardThemes': [],
        'rewardCurrency': [],
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        String itemType = item['itemType'] ?? '';
        item['id'] = doc.id;
        // Categorize items by their type
        if (itemType == 'theme') {
          categorizedItems['themes']!.add(item);
        } else if (itemType == 'image') {
          categorizedItems['images']!.add(item);
        } else if (itemType == 'rewardImage') {
          categorizedItems['rewardImages']!.add(item);
        } else if (itemType == 'rewardTheme') {
          categorizedItems['rewardThemes']!.add(item);
        } else if (itemType == 'rewardCurrency') {
          categorizedItems['rewardCurrency']!.add(item);
        }
      }
      _storeItems.value = categorizedItems; // Update the reactive variable
    } catch (error) {
      print("Error loading initial store items: $error");
      _storeItems.value = {
        'themes': [],
        'images': [],
        'rewardImages': [],
        'rewardThemes': [],
        'rewardCurrency': [],
      }; // Handle errors by resetting categories
    }
  }

  void loadInitialOwnedItems() async {
    try {
      String uid = LoggedInUserService.instance.getUid()!;
      DocumentSnapshot snapshot =
      await _firestore.collection('storeProfiles').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _itemsOwned.value = List<String>.from(data['ownedItems'] ?? []);
        print(_itemsOwned.value);
      } else {
        print("storeProfile doesnt exists");
        _itemsOwned.value = []; // If document doesn't exist, set an empty list
      }
    } catch (error) {
      print("Error loading initial owned items: $error");
      _itemsOwned.value = []; // Handle errors by resetting the list
    }
  }

  void listenToOwnedItems() {
    String uid = LoggedInUserService.instance.getUid()!;
    _firestore.collection('storeProfiles').doc(uid).snapshots().listen((
        snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _itemsOwned.value = List<String>.from(data['ownedItems'] ?? []);
      } else {
        _itemsOwned.value = []; // If document doesn't exist, clear the list
      }
    }, onError: (error) {
      print("Error listening to owned items: $error");
      _itemsOwned.value = []; // Handle errors by resetting the list
    });
  }

  void listenToStoreItems() {
    _firestore.collection('storeItems').snapshots().listen((snapshot) {
      Map<String, List<Map<String, dynamic>>> categorizedItems = {
        'themes': [],
        'images': [],
        'rewardImages': [],
        'rewardThemes': [],
        'rewardCurrency': [],
      };

      for (var doc in snapshot.docs) {
        Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
        String itemType = item['itemType'] ?? '';
        item['id'] = doc.id;
        // Categorize items by their type
        if (itemType == 'theme') {
          categorizedItems['themes']!.add(item);
        } else if (itemType == 'image') {
          categorizedItems['images']!.add(item);
        } else if (itemType == 'rewardImage') {
          categorizedItems['rewardImages']!.add(item);
        } else if (itemType == 'rewardTheme') {
          categorizedItems['rewardThemes']!.add(item);
        } else if (itemType == 'rewardCurrency') {
          categorizedItems['rewardCurrency']!.add(item);
        }
      }
      _storeItems.value = categorizedItems; // Update the reactive variable
    });
  }

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

  bool isOwned(String itemId) {
    return this._itemsOwned.value.contains(itemId);
  }

  Future<void> buy(String itemId) async {
    String? userId = LoggedInUserService.instance.getUid();
    num availableMoney = LoggedInUserService.instance.observableCurrency.value;

    Map<String, dynamic>? itemData;
    for (var itemType in _storeItems.value.values) {
      for (var item in itemType) {
        if (item['id'] == itemId) {
          itemData = item;
          break;
        }
      }
      if (itemData != null) break;
    }
    if (itemData == null) {
      print("Item not found in cached store items.");
      return;
    }
    num itemCost = itemData['cost'] ?? 0;
    if (availableMoney < itemCost) {
      print("Not enough money.");
      return;
    }
    try {
      // Deduct currency and add item to owned
      await _firestore.collection('users').doc(userId).update({
        'currency': availableMoney - itemCost,
      });
      addToOwned(userId!, itemId);
      _purchaseTrigger.value++; // Trigger observers
      print("Purchase successful!");
    } catch (e) {
      print("Error during purchase: $e");
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> browseStoreItems() async {
    return _storeItems.value;
  }
}