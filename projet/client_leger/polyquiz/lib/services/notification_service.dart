import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/channelService.dart';

class NotificationService extends GetxController {
  final channelService = ChannelService.instance;
  static NotificationService get instance => Get.find();
  Map<String, int> channelMessageCount = {};
  Map<String, bool> isChannelRead = {};
  RxBool hasUnreadChannels = false.obs;

  @override
  void onInit() {
    super.onInit();
    setUpChannelListener();
  }

  bool isChannelPermitted(String channelId) => channelService.getListOfPermittedChannelIds().contains(channelId);

  void handlePermittedChannel(Canal channel) {
    if (channel.id == null) return;
    if (!channelMessageCount.containsKey(channel.id)) {
      channelMessageCount[channel.id!] = channel.messages.length;
      isChannelRead[channel.id!] = true;
      return;
    }

    if (channelMessageCount[channel.id] == null) return;

    if (channel.messages.length > channelMessageCount[channel.id]!) {
      channelMessageCount[channel.id!] = channel.messages.length;
      isChannelRead[channel.id!] = false;
      print("New unread message in ${channel.name}");
    }
  }

  void handleUnpermittedChannel(Canal channel) {
    if (channelMessageCount.containsKey(channel.id)) channelMessageCount.remove(channel.id);
    if (isChannelRead.containsKey(channel.id)) isChannelRead.remove(channel.id);
  }

  void updateUnreadChannelValue() {
    hasUnreadChannels = isChannelRead.containsValue(false).obs;
  }

  void readChannel(String channelId) {
    if (isChannelRead.containsKey(channelId)) isChannelRead[channelId] = true;
  }

  void setUpChannelListener() {
    channelService.getChannelStream().listen((snapshot) {
      snapshot.docChanges.forEach((element) {
        Canal changedChannel = Canal.fromDocument(element.doc);
        if (changedChannel.id == null) return;

        if (isChannelPermitted(changedChannel.id!)) handlePermittedChannel(changedChannel);
        else handleUnpermittedChannel(changedChannel);

        updateUnreadChannelValue();
      });
    });
  }

}