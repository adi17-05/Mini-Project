import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> predictHealth(Map<String, dynamic> input) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(input),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Prediction failed");
    }
  }
}
