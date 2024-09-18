import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService getInstance() {
    return SocketService();
  }

  void connect(String token) async {
    this.socket = IO.io(
      'http://ec2-35-183-137-76.ca-central-1.compute.amazonaws.com:8000',
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .disableAutoConnect()
        .build(),
    );

    this.socket.connect();

    socket.onConnect((_) {
       print('Connected to the socket server ${socket.id}');
    });
  }

  void sendMessage(String event, String message) {
    if (this.socket.connected) {
      this.socket.emit(event, message);

    }
  }

  void on(String event, Function(dynamic) callback) {
    this.socket.on(event, callback);
  }

  void disconnect() {
    this.socket.disconnect();
  }
}