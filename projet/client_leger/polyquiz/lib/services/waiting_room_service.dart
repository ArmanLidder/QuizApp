import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_service.dart';

class WaitingRoomService {
  static Future<String> createRoom(String quizId) async {
    final response = await HttpService.post('/create-room', {'quizId': quizId});

    // Check if the response is successful
    if (response.statusCode == 200) {
      // Parse the response body as JSON
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['roomId']; // Now this will work as responseData is a Map
    } else {
      throw Exception('Failed to create room');
    }
  }

  static void updateRoomLockStatus(String roomId, bool isLocked) {
    // Update the lock status in your backend
    HttpService.patch('/rooms/$roomId', {'locked': isLocked});
  }
}
