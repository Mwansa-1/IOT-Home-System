import 'dart:convert';
import 'package:http/http.dart' as http;

class BulbApi {
  final String baseUrl = 'https://9dszph8j-8002.uks1.devtunnels.ms';

  Future<void> bulbChat(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/weather/api/control-bulb-text-command/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to control bulb');
    }
  }
}
