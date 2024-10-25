import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';

String hardcodedUserId = "Kvw4qW583jXEdYuoBgVjRe5JeAK2";

class ChannelService extends GetxController {
  final String collectionName = "canals";
  static ChannelService get instance => Get.find();
  RxList<Canal> channels = <Canal>[].obs;
  RxList<Canal> permittedChannels = <Canal>[].obs;
  RxList<Canal> joinableChannels = <Canal>[].obs;

  final _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    channels.bindStream(getChannelStream());
    permittedChannels.bindStream(getPermittedChannelStream());
    joinableChannels.bindStream(getJoinableChannelStream());
  }

  Stream<List<Canal>> getChannelStream() {
    return _db.collection(collectionName)
        .snapshots()
        .map((query) {
       return query.docs.map((doc) => Canal.fromDocument(doc)).toList();
    });
  }

  Stream<List<Canal>> getPermittedChannelStream() {
    final isUserPermitted = (Canal channel) => channel.permittedUsers.contains(hardcodedUserId) || channel.name == "general";
    return _db.collection(collectionName)
        .snapshots()
        .map((query) => query.docs.map((doc) => Canal.fromDocument(doc)).where(isUserPermitted).toList());
  }

  Stream<List<Canal>> getJoinableChannelStream() {
    final isChannelIsJoinable = (Canal channel) => !(channel.name == 'general' || channel.isPrivate || channel.permittedUsers.contains(hardcodedUserId));
    return _db.collection(collectionName)
        .snapshots()
        .map((query) => query.docs.map((doc) => Canal.fromDocument(doc)).where(isChannelIsJoinable).toList());
  }

  Future<void> addMessage(String channelId, String content) async {
    Message message = Message(userUid: hardcodedUserId, message: content, createdAt: Timestamp.now());
    DocumentReference channelRef = _db.collection(collectionName).doc(channelId);
    await channelRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Future<void> joinChannel(String channelId) async {
    DocumentReference channelRef = _db.collection(collectionName).doc(channelId);
    await channelRef.update({
      'permittedUsers': FieldValue.arrayUnion([hardcodedUserId])
    });
  }

  Future<void> leaveChannel(String channelId) async {
    DocumentReference channelRef = _db.collection(collectionName).doc(channelId);
    await channelRef.update({
      'permittedUsers': FieldValue.arrayRemove([hardcodedUserId])
    });
  }
}
