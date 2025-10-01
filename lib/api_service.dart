import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your backend URL (use your LAN IP instead of 127.0.0.1 if testing on Chrome)
  static const String baseUrl = "http://127.0.0.1:5000";//192.168.29.12


  static Future<String> getPrediction(
      double buyPrice,
      double sellPrice,
      double quantity,
      double holdingPeriod,
      double profitLoss,
      ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "features": [
          buyPrice,
          sellPrice,
          quantity,
          holdingPeriod,
          profitLoss,
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return "${data['prediction']} - ${data['description']}";
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }
}
