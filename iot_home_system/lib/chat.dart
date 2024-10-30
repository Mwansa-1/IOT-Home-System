import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Bulb API service class
class BulbApi {
  final String baseUrl = 'https://9dszph8j-8002.uks1.devtunnels.ms';

  Future<String> bulbChat(String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/weather/api/control-bulb-text-command/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': action}),
    );

    if (response.statusCode == 200) {
      // Parse and return the response from the server (if needed)
      return response.body; // Assuming the API sends a response back
    } else {
      throw Exception('Failed to control bulb');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final BulbApi _bulbApi = BulbApi(); // Instance of the BulbApi class
  List<Map<String, dynamic>> _messages = []; // To store the chat history

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isSender': true}); // Add sender's message
    });

    try {
      // Call the API and get the response
      final response = await _bulbApi.bulbChat(text);

      // Add the response from the API to the chat
      setState(() {
        _messages.add({'text': response, 'isSender': false});
      });
    } catch (e) {
      setState(() {
        _messages
            .add({'text': 'Failed to send command: $e', 'isSender': false});
      });
    }

    _controller.clear(); // Clear the input field after sending
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6C3D1B), // Custom brown color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7DFBF),
              Color(0xFFBB6431),
              Color(0xFF6C3D1B), // #6C3D1B
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
            child: Column(
              children: [
                // Chat Bubbles
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildChatBubble(
                          text: _messages[index]['text'],
                          isSender: _messages[index]['isSender'],
                        );
                      },
                    ),
                  ),
                ),
                // Text Input Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your command here...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          _sendMessage(_controller.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to create chat bubbles
  Widget _buildChatBubble({required String text, required bool isSender}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSender ? Color(0xFFBB6431) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.0),
            topRight: Radius.circular(18.0),
            bottomLeft: Radius.circular(isSender ? 18.0 : 0.0),
            bottomRight: Radius.circular(isSender ? 0.0 : 18.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
