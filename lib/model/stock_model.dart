class StockModel {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isPositive;
  final String volume;
  final String high;
  final String low;
  final String open;
  final String marketCap;
  final String pe;
  final DateTime lastUpdated;

  StockModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isPositive,
    required this.volume,
    required this.high,
    required this.low,
    required this.open,
    required this.marketCap,
    required this.pe,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '0.0',
      change: json['change'] ?? '0.0%',
      isPositive: json['isPositive'] ?? false,
      volume: json['volume'] ?? 'N/A',
      high: json['high'] ?? 'N/A',
      low: json['low'] ?? 'N/A',
      open: json['open'] ?? 'N/A',
      marketCap: json['marketCap'] ?? 'N/A',
      pe: json['pe'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'isPositive': isPositive,
      'volume': volume,
      'high': high,
      'low': low,
      'open': open,
      'marketCap': marketCap,
      'pe': pe,
    };
  }

  StockModel copyWith({
    String? symbol,
    String? name,
    String? price,
    String? change,
    bool? isPositive,
    String? volume,
    String? high,
    String? low,
    String? open,
    String? marketCap,
    String? pe,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      price: price ?? this.price,
      change: change ?? this.change,
      isPositive: isPositive ?? this.isPositive,
      volume: volume ?? this.volume,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      marketCap: marketCap ?? this.marketCap,
      pe: pe ?? this.pe,
      lastUpdated: DateTime.now(),
    );
  }
}