import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'sensor_api.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:time/time.dart';
import 'chat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isBulbOn = false;
  String temperature = 'Loading...';
  String humidity = 'Loading...';
  late WebViewController controller;

  final SensorApi sensorApi = SensorApi();

  @override
  void initState() {
    super.initState();
    _fetchBulbState();
    _fetchSensorData();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('http://192.168.43.132'),
      );
  }

  // Fetch sensor data
  Future<void> _fetchSensorData() async {
    try {
      final sensorData = await sensorApi.getSensorHistory();
      setState(() {
        // Truncate temperature to 2 decimal places
        double temp = sensorData[0]['temperature'];
        temperature = '${temp.toStringAsFixed(1)} °C';

        // Truncate humidity to 2 decimal places (if needed)
        double hum = sensorData[0]['humidity'];
        humidity = '${hum.toStringAsFixed(1)} %';
      });
    } catch (e) {
      setState(() {
        temperature = 'Error';
        humidity = 'Error';
      });
      print(e);
    }
  }

  Future<void> _fetchBulbState() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.43.52:8002/weather/api/get-bulb-state/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isBulbOn = data['state'] == 'ON';
        });
      } else {
        throw Exception('Failed to load bulb state');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _controlBulb(bool turnOn) async {
    try {
      final action = turnOn ? 'TURN_ON' : 'TURN_OFF';
      final response = await http.post(
        Uri.parse('http://192.168.43.52:8002/weather/api/control-bulb/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isBulbOn = turnOn;
        });
      } else {
        throw Exception('Failed to control bulb');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.51, 0.64, 0.99],
            colors: [
              Color(0xFF6C3D1B), // #6C3D1B
              Color(0xFFBB6431), // #BB6431
              Color(0xFFF7DFBF), // #F7DFBF
            ],
            transform: GradientRotation(169.7 *
                (3.141592653589793 / 180)), // Convert degrees to radians
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'imicele',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 180),
                        IconButton(
                          icon: Icon(
                            Icons.message,
                            color: Color(0xFF6C3D1B),
                            size: 30.0,
                          ),
                          onPressed: () {
                            // navigate to the chat screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '12:45',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '15 September 2024',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Live Image Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        // image: DecorationImage(
                        //   image: NetworkImage(
                        //     'https://example.com/image.jpg', // Replace with your image URL
                        //   ),
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      child: WebViewWidget(
                        controller: controller,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Grid Cards Section
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    StatusCard(
                      icon: Icons.thermostat,
                      title: 'Temperature',
                      value: temperature,
                    ),
                    StatusCard(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: humidity,
                    ),
                    StatusCard(
                      icon: Icons.cloud,
                      title: 'Precipitation',
                      value: '0%',
                    ),
                    StatusCard(
                      icon: Icons.lightbulb_outline,
                      title: 'Light Bulb',
                      value: isBulbOn ? 'On' : 'Off',
                      isSwitch: true,
                      switchValue: isBulbOn,
                      onSwitchChanged: (bool newValue) {
                        _controlBulb(newValue);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  const StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF4D240B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (isSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
            )
          else
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }
}
