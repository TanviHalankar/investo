// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class TradePredictionScreen extends StatefulWidget {
//   final String tradeId; // ID of the trade document in Firebase
//   const TradePredictionScreen({Key? key, required this.tradeId})
//       : super(key: key);
//
//   @override
//   _TradePredictionScreenState createState() => _TradePredictionScreenState();
// }
//
// class _TradePredictionScreenState extends State<TradePredictionScreen> {
//   bool isLoading = true;
//   String predictionResult = "Fetching...";
//   Map<String, dynamic>? tradeData;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTradeAndPredict();
//   }
//
//   Future<void> fetchTradeAndPredict() async {
//     try {
//       // Step 1: Get data from Firebase
//       final doc = await FirebaseFirestore.instance
//           .collection("trades")
//           .doc(widget.tradeId)
//           .get();
//
//       if (!doc.exists) {
//         setState(() {
//           predictionResult = "Trade not found!";
//           isLoading = false;
//         });
//         return;
//       }
//
//       tradeData = doc.data();
//
//       // Step 2: Call Model API
//       final response = await http.post(
//         Uri.parse("http://127.0.0.1:5000/predict"), // your model API endpoint
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(tradeData),
//       );
//
//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         setState(() {
//           predictionResult =
//           "Predicted P/L: ₹${result['predicted_pl']} \nSuccess Probability: ${result['success_prob']}%";
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           predictionResult = "Error: ${response.statusCode}";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         predictionResult = "Error: $e";
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Trade Prediction")),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator()
//             : Card(
//           margin: EdgeInsets.all(20),
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16)),
//           elevation: 6,
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Prediction Result",
//                     style: TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold)),
//                 SizedBox(height: 10),
//                 Text(predictionResult,
//                     style: TextStyle(fontSize: 16),
//                     textAlign: TextAlign.center),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: fetchTradeAndPredict,
//                   child: Text("Recalculate"),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
