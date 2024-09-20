import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  SocketService._internal();

  factory SocketService() {
      return _instance;
  }

  void connect(String token) {
    if (socket == null) {
      socket = IO.io(
      'http://ec2-35-183-137-76.ca-central-1.compute.amazonaws.com:8000',
      // "http://10.0.2.2:8000", // pour debug en localhost
      IO.OptionBuilder()
        .enableForceNew()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build(),
      );
      
      socket!.connect();
          
      socket!.onConnect((_) {
          print('Connected to the socket server ${socket!.id}');
      });
          
      socket?.onDisconnect((_) {
          print('Disconnected to the socket server');
      });

    };
  }
 
  void sendMessage(String event, String message) {
    if (socket != null) {
      socket!.emit(event, message);
    }
  }

  void on(String event, Function(dynamic) callback) {
    if (socket != null) {
      socket!.on(event, callback);
    }
  }

  void disconnect() {
    socket!.disconnect();
    socket = null;
  }
}
