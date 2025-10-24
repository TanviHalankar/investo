import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RealTimeService {
  // Finnhub API configuration
  static const String apiKey = "d3ekatpr01qh40fepir0d3ekatpr01qh40fepirg"; // Replace with your Finnhub API key
  static const String baseUrl = "https://finnhub.io/api/v1";
  static const String wsUrl = "wss://ws.finnhub.io?token=$apiKey";

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _stockUpdatesController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _marketUpdatesController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final StreamController<Map<String, dynamic>> _chartDataController = StreamController<Map<String, dynamic>>.broadcast();

  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _mockDataTimer;

  // Store the current stock data
  List<Map<String, dynamic>> _currentStockData = [];
  final List<String> _stockSymbols = ['RELIANCE.BSE', 'TCS.BSE', 'INFY.BSE', 'WIPRO.BSE', 'HDFCBANK.BSE'];
  final Random _random = Random();

  // Singleton pattern
  static final RealTimeService _instance = RealTimeService._internal();
  factory RealTimeService() => _instance;
  RealTimeService._internal() {
    _currentStockData = getMockStockData(); // Initialize with mock data
  }

  Stream<Map<String, dynamic>> get stockUpdates => _stockUpdatesController.stream;
  Stream<List<Map<String, dynamic>>> get marketUpdates => _marketUpdatesController.stream;
  Stream<Map<String, dynamic>> get chartDataUpdates => _chartDataController.stream;

  bool get isConnected => _isConnected;

  void connect() {
    try {
      // Connect to Finnhub WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Subscribe to stock symbols
      for (var symbol in _stockSymbols) {
        _channel!.sink.add(json.encode({
          "type": "subscribe",
          "symbol": symbol
        }));
      }

      // Listen for messages
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          print("WebSocket error: $error");
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print("WebSocket connection closed");
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      // Initialize stock data from REST API
      _initializeStockData();
      
      // Set up ping timer to keep connection alive
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _channel?.sink.add(json.encode({"type": "ping"}));
      });

      _isConnected = true;
      print("Connected to Finnhub WebSocket");
    } catch (e) {
      print("Failed to connect to Finnhub: $e");
      _isConnected = false;
      _fallbackToMockData();
    }
  }

  void _handleWebSocketMessage(dynamic data) {
    if (data['type'] == 'trade') {
      final trades = data['data'];
      if (trades != null && trades.isNotEmpty) {
        final trade = trades[0];
        final symbol = trade['s'];
        final price = trade['p'];
        final volume = trade['v'];
        
        // Update stock data
        final stockIndex = _currentStockData.indexWhere((stock) => stock['symbol'] == symbol);
        if (stockIndex != -1) {
          final stock = _currentStockData[stockIndex];
          final oldPrice = double.parse(stock['price'].toString().replaceAll(',', ''));
          final isPositive = price >= oldPrice;
          final changePercent = ((price - oldPrice) / oldPrice) * 100;
          
          final updatedStock = Map<String, dynamic>.from(stock);
          updatedStock['price'] = price.toStringAsFixed(2);
          updatedStock['change'] = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';
          updatedStock['isPositive'] = isPositive;
          updatedStock['volume'] = '${(volume / 1000000).toStringAsFixed(1)}M';
          
          // Update in the stock data list
          _currentStockData[stockIndex] = updatedStock;
          
          // Send individual stock update
          _stockUpdatesController.add(updatedStock);
          
          // Send market update
          _marketUpdatesController.add(_currentStockData);
        }
      }
    }
  }

  Future<void> _initializeStockData() async {
    try {
      List<Map<String, dynamic>> stockData = [];
      
      // Fetch data for each stock symbol
      for (var symbol in _stockSymbols) {
        final quoteData = await _fetchQuote(symbol);
        final profileData = await _fetchCompanyProfile(symbol);
        
        if (quoteData != null && profileData != null) {
          final price = quoteData['c'] ?? 0.0;
          final previousClose = quoteData['pc'] ?? 0.0;
          final changePercent = ((price - previousClose) / previousClose) * 100;
          final isPositive = changePercent >= 0;
          
          stockData.add({
            'symbol': symbol,
            'name': profileData['name'] ?? symbol,
            'price': price.toStringAsFixed(2),
            'change': '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
            'isPositive': isPositive,
            'volume': '${(quoteData['v'] / 1000000).toStringAsFixed(1)}M',
            'high': quoteData['h'].toStringAsFixed(2),
            'low': quoteData['l'].toStringAsFixed(2),
            'open': quoteData['o'].toStringAsFixed(2),
            'marketCap': '₹${(profileData['marketCapitalization'] / 1000).toStringAsFixed(1)}L Cr',
            'pe': profileData['pe']?.toStringAsFixed(1) ?? 'N/A',
          });
        }
        
        // Add delay to avoid API rate limits
        await Future.delayed(Duration(milliseconds: 200));
      }
      
      if (stockData.isNotEmpty) {
        _currentStockData = stockData;
        _marketUpdatesController.add(_currentStockData);
      } else {
        throw Exception("Failed to fetch stock data");
      }
    } catch (e) {
      print("Error initializing stock data: $e");
      _fallbackToMockData();
    }
  }

  Future<Map<String, dynamic>?> _fetchQuote(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching quote for $symbol: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchCompanyProfile(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching company profile for $symbol: $e");
      return null;
    }
  }

  void _fallbackToMockData() {
    print("Falling back to mock data");
    _currentStockData = getMockStockData();
    _marketUpdatesController.add(_currentStockData);
    _startMockUpdates();
  }

  void _startMockUpdates() {
    // Cancel any existing timer
    _mockDataTimer?.cancel();

    // Set up timer to send periodic updates
    _mockDataTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      // Update random stocks
      _updateRandomStocks();

      // Send market update
      _marketUpdatesController.add(_currentStockData);
    });
  }

  void _updateRandomStocks() {
    // Update 1-3 random stocks
    final updateCount = _random.nextInt(3) + 1;

    for (int i = 0; i < updateCount; i++) {
      final stockIndex = _random.nextInt(_currentStockData.length);
      final stock = _currentStockData[stockIndex];

      // Generate new price with small variation
      final currentPrice = double.parse(stock['price'].toString().replaceAll(',', ''));
      final changePercent = (_random.nextDouble() * 2 - 1) * 0.5; // -0.5% to +0.5%
      final newPrice = currentPrice * (1 + changePercent / 100);

      // Update price and change percentage
      final isPositive = changePercent >= 0;
      final formattedPrice = newPrice.toStringAsFixed(2);
      final formattedChange = '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

      // Create updated stock data
      final updatedStock = Map<String, dynamic>.from(stock);
      updatedStock['price'] = formattedPrice;
      updatedStock['change'] = formattedChange;
      updatedStock['isPositive'] = isPositive;

      // Update in the mock data list
      _currentStockData[stockIndex] = updatedStock;

      // Send individual stock update
      _stockUpdatesController.add(updatedStock);

      // Generate and send chart data if subscribed
      _generateAndSendChartData(updatedStock['symbol']);
    }
  }

  void _generateAndSendChartData(String symbol) {
    // Generate random chart data for the stock
    final chartData = {
      'symbol': symbol,
      'period': '1D',
      'data': List.generate(
          78,
          (i) => 100 + _random.nextDouble() * 10 - 5 + (i * 0.1)
      )
    };

    // Send chart data update
    _chartDataController.add(chartData);
  }

  Future<List<Map<String, dynamic>>> fetchHistoricalData(String symbol, String resolution, int from, int to) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$apiKey')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['s'] == 'ok') {
          List<Map<String, dynamic>> candles = [];
          
          for (int i = 0; i < data['t'].length; i++) {
            candles.add({
              'timestamp': data['t'][i],
              'open': data['o'][i],
              'high': data['h'][i],
              'low': data['l'][i],
              'close': data['c'][i],
              'volume': data['v'][i],
            });
          }
          
          return candles;
        }
      }
      throw Exception("Failed to fetch historical data");
    } catch (e) {
      print("Error fetching historical data: $e");
      return _generateMockHistoricalData(symbol);
    }
  }

  List<Map<String, dynamic>> _generateMockHistoricalData(String symbol) {
    final basePrice = 100.0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final oneDayAgo = now - 86400;
    
    return List.generate(24, (i) {
      final timestamp = oneDayAgo + (i * 3600);
      final hourFactor = (i % 12) / 12;
      final price = basePrice * (1 + (hourFactor - 0.5) * 0.1);
      
      return {
        'timestamp': timestamp,
        'open': price - _random.nextDouble() * 2,
        'high': price + _random.nextDouble() * 3,
        'low': price - _random.nextDouble() * 3,
        'close': price + _random.nextDouble() * 2,
        'volume': 10000 + _random.nextInt(50000),
      };
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), connect);
  }

  void subscribeToStock(String symbol) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(json.encode({
        "type": "subscribe",
        "symbol": symbol
      }));
    }
    
    // Generate initial chart data
    _generateAndSendChartData(symbol);
  }

  void unsubscribeFromStock(String symbol) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(json.encode({
        "type": "unsubscribe",
        "symbol": symbol
      }));
    }
  }

  Future<Map<String, dynamic>> getStockDetails(String symbol) async {
    try {
      final quoteData = await _fetchQuote(symbol);
      final profileData = await _fetchCompanyProfile(symbol);
      
      if (quoteData != null && profileData != null) {
        final price = quoteData['c'] ?? 0.0;
        final previousClose = quoteData['pc'] ?? 0.0;
        final changePercent = ((price - previousClose) / previousClose) * 100;
        final isPositive = changePercent >= 0;
        
        return {
          'symbol': symbol,
          'name': profileData['name'] ?? symbol,
          'price': price.toStringAsFixed(2),
          'change': '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
          'isPositive': isPositive,
          'volume': '${(quoteData['v'] / 1000000).toStringAsFixed(1)}M',
          'high': quoteData['h'].toStringAsFixed(2),
          'low': quoteData['l'].toStringAsFixed(2),
          'open': quoteData['o'].toStringAsFixed(2),
          'marketCap': '₹${(profileData['marketCapitalization'] / 1000).toStringAsFixed(1)}L Cr',
          'pe': profileData['pe']?.toStringAsFixed(1) ?? 'N/A',
        };
      }
      
      throw Exception("Failed to fetch stock details");
    } catch (e) {
      print("Error getting stock details: $e");
      
      // Return mock data for the requested symbol
      final stock = _currentStockData.firstWhere(
        (s) => s['symbol'] == symbol,
        orElse: () => _currentStockData.first
      );
      
      return stock;
    }
  }

  Future<List<Map<String, dynamic>>> getMarketData() async {
    if (_currentStockData.isEmpty) {
      await _initializeStockData();
    }
    return _currentStockData;
  }

  // Mock data for development when backend is not available
  List<Map<String, dynamic>> getMockStockData() {
    return [
      {'symbol': 'RELIANCE.BSE', 'name': 'RELIANCE INDUSTRIES', 'price': '2,847.50', 'change': '+5.22%', 'isPositive': true, 'volume': '3.2M', 'high': '2,890.00', 'low': '2,820.00', 'open': '2,835.00', 'marketCap': '₹19.2L Cr', 'pe': '25.3'},
      {'symbol': 'TCS.BSE', 'name': 'TATA CONSULTANCY SERVICES', 'price': '3,456.80', 'change': '+3.15%', 'isPositive': true, 'volume': '2.8M', 'high': '3,480.00', 'low': '3,420.00', 'open': '3,430.00', 'marketCap': '₹12.6L Cr', 'pe': '28.5'},
      {'symbol': 'INFY.BSE', 'name': 'INFOSYS LIMITED', 'price': '1,567.30', 'change': '+2.89%', 'isPositive': true, 'volume': '4.1M', 'high': '1,580.00', 'low': '1,550.00', 'open': '1,555.00', 'marketCap': '₹6.5L Cr', 'pe': '26.8'},
      {'symbol': 'WIPRO.BSE', 'name': 'WIPRO LIMITED', 'price': '445.20', 'change': '-2.34%', 'isPositive': false, 'volume': '5.2M', 'high': '455.00', 'low': '442.00', 'open': '453.00', 'marketCap': '₹2.4L Cr', 'pe': '22.1'},
      {'symbol': 'HDFCBANK.BSE', 'name': 'HDFC BANK LIMITED', 'price': '1,634.70', 'change': '+1.45%', 'isPositive': true, 'volume': '6.3M', 'high': '1,650.00', 'low': '1,620.00', 'open': '1,625.00', 'marketCap': '₹12.3L Cr', 'pe': '19.7'},
    ];
  }

  void dispose() {
    _channel?.sink.close();
    _stockUpdatesController.close();
    _marketUpdatesController.close();
    _chartDataController.close();
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _mockDataTimer?.cancel();
    _isConnected = false;
  }
}