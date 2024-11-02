import 'package:audioplayers/audioplayers.dart';
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
  final player = AudioPlayer();


  @override
  void onInit() {
    super.onInit();
    setUpChannelListener();
    setUpMaps();
  }

  bool isChannelPermitted(String channelId) => channelService.getListOfPermittedChannelIds().contains(channelId);

  void handlePermittedChannel(Canal channel) {
    if (channel.id == null) return;
    if (!channelMessageCount.containsKey(channel.id)) {
      channelMessageCount[channel.id!] = channel.messages.length;
      isChannelRead[channel.id!] = false;
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
    hasUnreadChannels.value = isChannelRead.containsValue(false);
    playNotificationNoise();
  }

  void playNotificationNoise() {
    player.play(AssetSource('notification.mp3'));
  }

  void readChannel(String channelId) {
    if (isChannelRead.containsKey(channelId)) isChannelRead[channelId] = true;
    updateUnreadChannelValue();
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

  void setUpMaps() {
    channelService.permittedChannels.forEach((channel) {
      if (channel.id == null) return;
      isChannelRead[channel.id!] = true;
      channelMessageCount[channel.id!] = channel.messages.length;
    });
  }
}