import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';

class ChannelService extends GetxController {
  final String collectionName = "canals";
  static ChannelService get instance => Get.find();
  var channels = <Canal>[].obs;

  final _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    channels.bindStream(getChannelStream());
  }

  Stream<List<Canal>> getChannelStream() {
    return _db.collection(collectionName)
        .snapshots()
        .map((query) {
       return query.docs.map((doc) => Canal.fromDocument(doc)).toList();
    });
  }
}
