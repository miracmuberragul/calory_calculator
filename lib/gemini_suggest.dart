import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({super.key});

  @override
  State<GeminiChatScreen> createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final url = Uri.parse(
        'http://127.0.0.1:5000/ask_gemini',
      ); // <- EMULATOR IP
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': message}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _response = data['response'];
        });
      } else {
        setState(() {
          _response = 'Sunucu hatası: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beslenme Chatbotu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Text(_response, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Sorunuzu yazın...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final question = _controller.text.trim();
                    if (question.isNotEmpty) {
                      sendMessage(question);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
