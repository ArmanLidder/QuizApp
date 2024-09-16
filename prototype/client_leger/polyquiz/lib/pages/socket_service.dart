import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  SocketService getInstance() {
    return SocketService();
  }

  void connect(String token) async {
    print('Attempting to connect with token: $token');
    this.socket = IO.io(
      'http://ec2-35-183-137-76.ca-central-1.compute.amazonaws.com:8000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    this.socket.connect();

    print('Socket connection attempt made');
  }

  void sendMessage(String event, String message) {
    if (this.socket.connected) {
      this.socket.emit(event, message);
      print('Message sent: $event - $message');
    } else {
      print('Cannot send message: Socket not connected');
    }
  }

  void on(String event, Function(dynamic) callback) {
    this.socket.on(event, callback);
  }

  void disconnect() {
    if (socket.connected) {
      this.socket.clearListeners();
      this.socket.disconnect();
      print('Socket disconnected');
    } else {
      print('Socket already disconnected');
    }
  }
}