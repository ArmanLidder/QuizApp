import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:polyquiz/constants/constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  static final String baseUrl = IP_URL;
  static final String socketUrl = baseUrl + '/';
  IO.Socket? _socket;

  // Add a counter to track the number of active listeners
  int _listenerCount = 0;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  void connect([String? id]) {
    if (_socket == null) {
      print('Connecting to socket server with id: $id');
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
    _listenerCount = 0; // Reset listener count on disconnect
  }

  void sendMessage(String event, [dynamic data]) {
    if (data != event) {
      _socket?.emit(event, data);
    } else {
      _socket?.emit(event);
    }
  }

  // Modified onMessage to increment listener count
  void onMessage(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
    _listenerCount++; // Increment the count each time a listener is added
  }

  void sendMessageWithAck(String event, dynamic data, Function(dynamic) ack) {
    _socket?.emitWithAck(event, data, ack: ack);
  }

  void clearAllListeners() {
    _socket?.clearListeners();
    _socket?.off('*');
    _listenerCount = 0; // Reset listener count when all listeners are cleared
  }

  void clearListener(String event) {
    _socket?.off(event);
    if (_listenerCount > 0) {
      _listenerCount--; // Decrement count if a listener is removed
    }
  }

  bool isSocketAlive() {
    return _socket != null && _socket!.connected;
  }

  // New method to get the current listener count
  int getListenerCount() {
    return _listenerCount;
  }
}
