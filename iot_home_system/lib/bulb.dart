import 'dart:convert';
import 'package:http/http.dart' as http;

class BulbApi {
  final String baseUrl = 'http://192.168.43.52:8002';

  Future<String> getBulbState() async {
    final response =
        await http.get(Uri.parse('$baseUrl/weather/api/get-bulb-state/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['state'];
    } else {
      throw Exception('Failed to load bulb state');
    }
  }

  Future<void> controlBulb(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/weather/api/control-bulb/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to control bulb');
    }
  }
}
