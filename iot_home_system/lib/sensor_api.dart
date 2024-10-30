import 'dart:convert';
import 'package:http/http.dart' as http;

class SensorApi {
  final String baseUrl = 'http://192.168.43.52:8002';

  Future<List<Map<String, dynamic>>> getSensorHistory() async {
    final response =
        await http.get(Uri.parse('$baseUrl/weather/api/get-sensor-history/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Make sure the data returned is a list of maps with temperature and humidity
      return List<Map<String, dynamic>>.from(data.map((item) => {
            'timestamp': item['timestamp'],
            'temperature': item['temperature'],
            'humidity': item['humidity'],
          }));
    } else {
      throw Exception('Failed to load sensor history');
    }
  }
}
