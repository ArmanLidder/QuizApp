import 'package:polyquiz/services/logged_in_user_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:polyquiz/constants/constants.dart';
import 'package:get/get.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  final LoggedInUserService loggedInUserService = Get.find();
  static final String baseUrl = IP_URL;
  static final String socketUrl = baseUrl + '/';
  IO.Socket? _socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void connect() {
    if (_socket == null) {
      String? id = this.loggedInUserService.getUid();
      _socket = IO.io(socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'upgrade': false,
        'auth': {'userId': id}
      });

      _socket?.on('connect', (_) {
        print('Connected to socket server');
      });

      _socket?.on('disconnect', (_) {
        print('Disconnected from socket server');
      });

      _socket?.connect();
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void sendMessage(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void onMessage(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void sendMessageWithAck(String event, dynamic data, Function(dynamic) ack) {
    _socket?.emitWithAck(event, data, ack: ack);
  }

  void clearAllListeners() {
    _socket?.clearListeners();
    _socket?.off('*');
  }

  bool isSocketAlive() {
    return _socket != null && _socket!.connected;
  }
}
