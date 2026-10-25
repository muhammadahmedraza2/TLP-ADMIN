import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _chatUrl =
      "http://tlp-election-api.runasp.net/api/Chat/ask";

  static Future<String> askQuestion(String message) async {
    final response = await http.post(
      Uri.parse(_chatUrl),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"message": message}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      return decoded['reply'] ?? "Maazrat, jawab nahi mil saka.";
    }

    throw Exception(
      "Chat se jawab nahi mila: "
      "${response.statusCode} - ${response.body}",
    );
  }
}
