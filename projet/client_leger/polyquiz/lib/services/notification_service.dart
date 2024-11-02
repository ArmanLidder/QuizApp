import 'package:get/get.dart';
import 'package:polyquiz/services/channelService.dart';

class NotificationService extends GetxController {
  final channelService = ChannelService.instance;
  static NotificationService get instance => Get.find();
  Map<String, int> channelMessageCount = {};
  Map<String, bool> isChannelRead = {};



}