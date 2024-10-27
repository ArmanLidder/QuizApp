import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class ChannelService extends GetxController {
  final loggedInService = Get.put(LoggedInUserService());
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
    final isUserPermitted = (Canal channel) => channel.permittedUsers.contains(loggedInService.user?.uid) || channel.name == "general";
    return _db.collection(collectionName)
        .snapshots()
        .map((query) => query.docs.map((doc) => Canal.fromDocument(doc)).where(isUserPermitted).toList());
  }

  Stream<List<Canal>> getJoinableChannelStream() {
    final isChannelIsJoinable = (Canal channel) => !(channel.name == 'general' || channel.isPrivate || channel.permittedUsers.contains(loggedInService.user?.uid));
    return _db.collection(collectionName)
        .snapshots()
        .map((query) => query.docs.map((doc) => Canal.fromDocument(doc)).where(isChannelIsJoinable).toList());
  }

  Future<void> addMessage(String channelId, String content) async {
    Message message = Message(userUid: loggedInService.user?.uid ?? "", message: content, createdAt: Timestamp.now());
    DocumentReference channelRef = _db.collection(collectionName).doc(channelId);
    await channelRef.update({
      'messages': FieldValue.arrayUnion([message.toJson()])
    });
  }

  Future<void> joinChannel(String channelId) async {
    DocumentReference channelRef = _getChannelRefById(channelId);
    await channelRef.update({
      'permittedUsers': FieldValue.arrayUnion([loggedInService.user?.uid])
    });
  }

  Future<void> leaveChannel(String channelId) async {
    DocumentReference channelRef = _getChannelRefById(channelId);
    await channelRef.update({
      'permittedUsers': FieldValue.arrayRemove([loggedInService.user?.uid])
    });
  }

  Future<void> deleteChannel(String channelId) async {
    DocumentReference channelRef = _getChannelRefById(channelId);
    final docSnapshot = await channelRef.get();
    if (docSnapshot.exists) {
      await channelRef.delete();
    }
  }

  Future<bool> createChannel(String channelName, List<String> permittedUsers, bool isPrivate) async {
    final querySnapshot = await _db.collection(collectionName).where('name', isEqualTo: channelName).limit(1).get();
    if (querySnapshot.docs.isNotEmpty) {
      return false;
    }

    Canal newChannel = Canal(
      name: channelName,
      permittedUsers: permittedUsers,
      isPrivate: isPrivate,
      messages: [],
    );

    await _db.collection(collectionName).add(newChannel.toJson());
    return true;
  }

  DocumentReference _getChannelRefById(String id) => _db.collection(collectionName).doc(id);
}
