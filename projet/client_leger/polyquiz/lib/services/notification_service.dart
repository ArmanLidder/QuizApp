import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:polyquiz/models/message.dart';
import 'package:polyquiz/services/background_notification_service.dart';
import 'package:polyquiz/services/channelService.dart';
import 'package:polyquiz/services/logged_in_user_service.dart';

class NotificationService extends GetxController {
  final channelService = ChannelService.instance;
  static NotificationService get instance => Get.find();
  Map<String, int> channelMessageCount = {};
  Map<String, bool> isChannelRead = {};
  RxBool hasUnreadChannels = false.obs;
  final player = AudioPlayer();
  bool isChatOpen = false;
  String? currentChannelId;


  @override
  void onInit() {
    super.onInit();
    setUpChannelListener();
    setUpMaps();
  }

  bool isChannelPermitted(String channelId) => channelService.getListOfPermittedChannelIds().contains(channelId);

  void clearCurrentChannel() => currentChannelId = null;

  void handlePermittedChannel(Canal channel) {
    if (channel.id == null) return;

    // this if clause is a false safe is a permitted channel hasn't been added
    // though in theory they should always be added by other means
    if (!channelMessageCount.containsKey(channel.id)) {
      channelMessageCount[channel.id!] = channel.messages.length;
      bool isNewChannel = channel.messages.length == 0;
      isChannelRead[channel.id!] = isNewChannel;
      if (isNewChannel) return;
      notify();
      return;
    }

    if (channelMessageCount[channel.id] == null) return;

    if (channel.messages.length > channelMessageCount[channel.id]!) {
      channelMessageCount[channel.id!] = channel.messages.length;
      if (channel.messages.last.userUid == LoggedInUserService.instance.user?.uid) return; // if the message was sent by user, ignore it
      if (channel.id == currentChannelId) return;
      isChannelRead[channel.id!] = false;
      notify();
    }
  }

  void handleUnpermittedChannel(Canal channel) {
    if (channelMessageCount.containsKey(channel.id)) channelMessageCount.remove(channel.id);
    if (isChannelRead.containsKey(channel.id)) isChannelRead.remove(channel.id);
  }

  void updateChannelMaps() {
    channelService.channels.forEach((channel) {
      if (channel.id == null) return;
      if (isChannelPermitted(channel.id!)) {
        if (channelMessageCount.containsKey(channel.id)) return; // no need to add channel if it's already in the list
        channelMessageCount[channel.id!] = channel.messages.length;
        isChannelRead[channel.id!] = true;
      } else {
        handleUnpermittedChannel(channel);
      }
    });
  }

  void updateUnreadChannelValue() {
    hasUnreadChannels.value = isChannelRead.containsValue(false);
  }

  void notify() {
    if (LoggedInUserService.instance.user == null) return;
    player.play(AssetSource('notification.mp3'));
    BackgroundNotificationService.instance.showNotification("Nouveau message", "Vous avez de nouveaux messages");
  }

  void readChannel(String channelId) {
    if (isChannelRead.containsKey(channelId)) isChannelRead[channelId] = true;
    updateUnreadChannelValue();
  }

  void setUpChannelListener() {
    channelService.getChannelStream().listen((snapshot) {
      snapshot.docChanges.forEach((element) {
        if (LoggedInUserService.instance.user == null) return; // if user isn't logged in, there shouldn't be a notification
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