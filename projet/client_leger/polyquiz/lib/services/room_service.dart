import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class RoomService {
  final String baseUrl = 'http://your-node-server-url.com'; // Replace with your server's URL

  Future<List<Room>> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/rooms'));

      if (response.statusCode == 200) {
        List<dynamic> roomsJson = json.decode(response.body);
        return roomsJson.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (error) {
      throw Exception('Error fetching rooms: $error');
    }
  }
}