// import 'dart:convert';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:http/http.dart' as http;
//
// class ApiService {
//   const ApiService();
//
//   // ✅ Use your current PC LAN IP (same as Flask host)
//   List<String> get _candidateBases {
//     // const lanIp = '192.168.29.12'; // replace with your system IP
//     const lanIp ='10.125.53.162';
//
//     if (kIsWeb) {
//       // Chrome/Web version
//       return ['http://192.168.29.12:5000'];
//
//     }
//
//     return [
//       'http://10.0.2.2:5000', // Android emulator
//       'http://192.168.29.12:5000', // Physical device (same Wi-Fi)
//       'http://127.0.0.1:5000', // Fallback
//     ];
//   }
//
//   Future<String> sendMessage(String message) async {
//     Object? lastErr;
//     for (final base in _candidateBases) {
//       try {
//         final resp = await http
//             .post(
//           Uri.parse('$base/chat'),
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode({"message": message}),
//         )
//             .timeout(const Duration(seconds: 30));
//
//         if (resp.statusCode == 200) {
//           final data = jsonDecode(resp.body) as Map<String, dynamic>;
//           return (data['reply'] as String?)?.trim().isNotEmpty == true
//               ? data['reply'] as String
//               : 'No reply';
//         } else {
//           lastErr = 'HTTP ${resp.statusCode}: ${resp.body}';
//         }
//       } catch (e) {
//         lastErr = e;
//       }
//     }
//
//     throw Exception('Unable to reach backend${lastErr != null ? ': $lastErr' : ''}');
//   }
// }
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  const ApiService();

  // 🔧 CHANGE THIS ONLY when your Wi-Fi / network changes
  // static const String lanIp = '192.168.29.12'; // replace with your system's LAN IP
  static const String lanIp = '10.125.53.162';

  // 🔗 Automatically uses this IP for all environments
  List<String> get _candidateBases {
    if (kIsWeb) {
      return ['http://$lanIp:5000'];
    }

    return [
      'http://10.0.2.2:5000', // Android emulator
      'http://$lanIp:5000',   // Physical device (same Wi-Fi)
      'http://127.0.0.1:5000', // Fallback
    ];
  }

  Future<String> sendMessage(String message) async {
    Object? lastErr;
    for (final base in _candidateBases) {
      try {
        final resp = await http
            .post(
          Uri.parse('$base/chat'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"message": message}),
        )
            .timeout(const Duration(seconds: 30));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          return (data['reply'] as String?)?.trim().isNotEmpty == true
              ? data['reply'] as String
              : 'No reply';
        } else {
          lastErr = 'HTTP ${resp.statusCode}: ${resp.body}';
        }
      } catch (e) {
        lastErr = e;
      }
    }

    throw Exception('Unable to reach backend${lastErr != null ? ': $lastErr' : ''}');
  }
}
