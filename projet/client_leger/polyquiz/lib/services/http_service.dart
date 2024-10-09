import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = 'http://192.168.56.1:3000/api';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data) async {
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
  }
}
