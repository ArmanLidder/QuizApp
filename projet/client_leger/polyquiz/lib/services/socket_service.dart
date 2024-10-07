import 'package:socket_io_client/socket_io_client.dart' as IO;

const localHost = "http://10.0.2.2:8000";
const deployedServer = 'http://ec2-35-183-137-76.ca-central-1.compute.amazonaws.com:8000';

const serverUrl = localHost;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? socket;

  SocketService._internal();

  factory SocketService() {
    return _instance;
  }

}
