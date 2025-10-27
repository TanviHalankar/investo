import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/real_time_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/guide_service.dart';


class EnhancedStockDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> stock;
  final Function(Map<String, dynamic>) onAddToWatchlist;
  final Function(Map<String, dynamic>) onRemoveFromWatchlist;
  final bool isInWatchlist;

  const EnhancedStockDetailsSheet({
    super.key,
    required this.stock,
    required this.onAddToWatchlist,
    required this.onRemoveFromWatchlist,
    required this.isInWatchlist,
  });

  @override
  State<EnhancedStockDetailsSheet> createState() => _EnhancedStockDetailsSheetState();
}

class _EnhancedStockDetailsSheetState extends State<EnhancedStockDetailsSheet> {
  // Color scheme
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  // Null-safe: determine positivity from field or change prefix
  bool _isPositive(Map<String, dynamic> stock) {
    final v = stock['isPositive'];
    if (v is bool) return v;
    final change = stock['change']?.toString() ?? '';
    return change.startsWith('+');
  }
  // Chart time periods
  String selectedPeriod = '1D';
  List<String> periods = ['1D', '1W', '1M', '3M', '1Y', '5Y'];

  // Trading state
  TextEditingController quantityController = TextEditingController(text: '1');
  String orderType = 'Market'; // Market or Limit
  TextEditingController limitPriceController = TextEditingController();
  
  // Real-time data
  final RealTimeService _realTimeService = RealTimeService();
  List<FlSpot> _chartData = [];
  Map<String, dynamic> _currentStock = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentStock = widget.stock;
    
    // Initialize chart data
    _chartData = _generateChartData();
    
    // Subscribe to real-time updates for this stock
    _realTimeService.subscribeToStock(widget.stock['symbol']);
    
    // Listen for stock updates
    _realTimeService.stockUpdates.listen((stockUpdate) {
      if (mounted && stockUpdate['symbol'] == widget.stock['symbol']) {
        setState(() {
          _currentStock = stockUpdate;
        });
      }
    });

    // Show trade guidance once when opening details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideService().show(GuideStep(
        id: 'trade_actions',
        title: 'Buy or Sell',
        message: 'Use BUY to purchase with demo cash or SELL to book profits. You earn points for trades!',
        bubbleAlignment: Alignment.topRight,
      ));
    });
    
    // Listen for chart data updates
    _realTimeService.chartDataUpdates.listen((chartData) {
      if (mounted && chartData['symbol'] == widget.stock['symbol'] && 
          chartData['period'] == selectedPeriod) {
        setState(() {
          if (chartData['data'] != null) {
            final List<dynamic> points = chartData['data'];
            _chartData = points.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), (entry.value as num).toDouble());
            }).toList();
          }
        });
      }
    });
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // Unsubscribe from real-time updates when leaving the page
    _realTimeService.unsubscribeFromStock(widget.stock['symbol']);
    quantityController.dispose();
    limitPriceController.dispose();
    super.dispose();
  }
  
  void _changePeriod(String period) {
    setState(() {
      selectedPeriod = period;
      _isLoading = true;
    });
    
    // Request new chart data for the selected period
    _realTimeService.connect();
    _realTimeService.subscribeToStock(widget.stock['symbol']);
    
    // Generate temporary chart data while waiting for real data
    setState(() {
      _chartData = _generateChartData();
      _isLoading = false;
    });
  }

  // Generate sample chart data based on period
  List<FlSpot> _generateChartData() {
    final random = DateTime.now().millisecondsSinceEpoch;
    final basePrice = double.parse(
      _currentStock['price']?.replaceAll(',', '') ??
      widget.stock['price'].replaceAll(',', '')
    );
  
    // Use null-safe positivity
    final source = _currentStock.isEmpty ? widget.stock : _currentStock;
    final isPositive = _isPositive(source);
  
    int dataPoints;
    switch (selectedPeriod) {
      case '1D':
        dataPoints = 78; // 5-min intervals in a trading day
        break;
      case '1W':
        dataPoints = 35; // 7 days * 5 data points per day
        break;
      case '1M':
        dataPoints = 30;
        break;
      case '3M':
        dataPoints = 60;
        break;
      case '1Y':
        dataPoints = 52;
        break;
      case '5Y':
        dataPoints = 60;
        break;
      default:
        dataPoints = 78;
    }

    List<FlSpot> spots = [];
    double currentPrice = basePrice * 0.95; // Start from 95% of current price

    for (int i = 0; i < dataPoints; i++) {
      // Add some randomness but trend towards current price
      double change = (basePrice - currentPrice) / (dataPoints - i);
      double randomFactor = ((random + i) % 100 - 50) / 1000;
      currentPrice += change + (currentPrice * randomFactor);
      spots.add(FlSpot(i.toDouble(), currentPrice));
    }

    return spots;
  }

  void _showBuySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTradingSheet('BUY'),
    );
  }

  void _showSellSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTradingSheet('SELL'),
    );
  }

  Widget _buildTradingSheet(String action) {
    final isBuy = action == 'BUY';
    final actionColor = isBuy ? positiveGreen : negativeRed;
    final currentPrice = double.parse(widget.stock['price'].replaceAll(',', ''));

    return StatefulBuilder(
      builder: (context, setSheetState) {
        final quantity = int.tryParse(quantityController.text) ?? 1;
        final price = orderType == 'Limit'
            ? (double.tryParse(limitPriceController.text) ?? currentPrice)
            : currentPrice;
        final totalAmount = quantity * price;

        return Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$action ${widget.stock['symbol']}',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Order Type Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: cardLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildOrderTypeButton(
                            'Market',
                            orderType == 'Market',
                                () => setSheetState(() => orderType = 'Market'),
                          ),
                        ),
                        Expanded(
                          child: _buildOrderTypeButton(
                            'Limit',
                            orderType == 'Limit',
                                () => setSheetState(() => orderType = 'Limit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Quantity Input
                  Text(
                    'Quantity',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(quantityController.text) ?? 1;
                          if (current > 1) {
                            setSheetState(() {
                              quantityController.text = (current - 1).toString();
                            });
                          }
                        },
                        icon: Icon(Icons.remove_circle_outline, color: textSecondary),
                      ),
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: cardLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) => setSheetState(() {}),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          int current = int.tryParse(quantityController.text) ?? 1;
                          setSheetState(() {
                            quantityController.text = (current + 1).toString();
                          });
                        },
                        icon: Icon(Icons.add_circle_outline, color: accentOrange),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Limit Price Input (if Limit order)
                  if (orderType == 'Limit') ...[
                    Text(
                      'Limit Price',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: limitPriceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardLight,
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          color: textSecondary,
                          fontSize: 18,
                        ),
                        hintText: currentPrice.toStringAsFixed(2),
                        hintStyle: TextStyle(color: textTertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) => setSheetState(() {}),
                    ),
                    SizedBox(height: 20),
                  ],

                  // Order Summary
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Price', '₹${price.toStringAsFixed(2)}'),
                        SizedBox(height: 12),
                        _buildSummaryRow('Quantity', quantity.toString()),
                        SizedBox(height: 12),
                        Divider(color: borderColor),
                        SizedBox(height: 12),
                        _buildSummaryRow(
                          'Total Amount',
                          '₹${totalAmount.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Place Order Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: actionColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showOrderConfirmation(action, quantity, price, totalAmount);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Place $action Order',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? darkBg : textSecondary,
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? textPrimary : textSecondary,
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textPrimary,
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Future<void> _showOrderConfirmation(String action, int quantity, double price, double total) async {
    try {
      final service = PortfolioService();
      final symbol = widget.stock['symbol'] as String;
      final name = (widget.stock['name'] ?? symbol) as String;

      if (action == 'BUY') {
        await service.buy(symbol: symbol, name: name, quantity: quantity, price: price);
      } else {
        await service.sell(symbol: symbol, name: name, quantity: quantity, price: price);
      }

      // complete guide step and award bonus
      await GuideService().complete('trade_actions');
      await GuideService().complete('first_trade', award: 50);

      if (!mounted) return;
      GuideService().show(GuideStep(
        id: 'order_placed',
        title: '$action placed',
        message: '$quantity x ${widget.stock['symbol']} @ ₹${price.toStringAsFixed(2)}. Check Portfolio for P&L.',
      ));
      Future.delayed(const Duration(seconds: 2), () => GuideService().hide());
    } catch (e) {
      if (!mounted) return;
      GuideService().show(GuideStep(
        id: 'order_failed',
        title: 'Order failed',
        message: '$e',
      ));
      Future.delayed(const Duration(seconds: 2), () => GuideService().hide());
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _generateChartData();
    final minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.1;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.stock['symbol'],
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.stock['name'] ?? widget.stock['symbol'],
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: cardLight,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded, color: textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Current Price
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Price',
                                style: TextStyle(
                                  color: textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${widget.stock['price']}',
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -1.5,
                                      height: 1.0,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isPositive(widget.stock)
                                          ? positiveGreen.withOpacity(0.15)
                                          : negativeRed.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      widget.stock['change'],
                                      style: TextStyle(
                                        color: _isPositive(widget.stock) ? positiveGreen : negativeRed,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Time Period Selector
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: periods.length,
                            itemBuilder: (context, index) {
                              final isSelected = periods[index] == selectedPeriod;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPeriod = periods[index];
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? accentOrange : cardLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      periods[index],
                                      style: TextStyle(
                                        color: isSelected ? darkBg : textSecondary,
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Interactive Chart
                        Container(
                          height: 250,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: (maxY - minY) / 4,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: borderColor,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 45,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '₹${value.toInt()}',
                                        style: TextStyle(
                                          color: textTertiary,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: minY - padding,
                              maxY: maxY + padding,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartData,
                                  isCurved: true,
                                  color: _isPositive(widget.stock) ? positiveGreen : negativeRed,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        (_isPositive(widget.stock) ? positiveGreen : negativeRed).withOpacity(0.3),
                                        (_isPositive(widget.stock) ? positiveGreen : negativeRed).withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  // tooltipBgColor: cardDark,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      return LineTooltipItem(
                                        '₹${spot.y.toStringAsFixed(2)}',
                                        TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Key Statistics
                        const Text(
                          'Key Statistics',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildStatRow('Volume', widget.stock['volume'] ?? 'N/A'),
                        _buildStatRow('Day High', '₹${widget.stock['high'] ?? 'N/A'}'),
                        _buildStatRow('Day Low', '₹${widget.stock['low'] ?? 'N/A'}'),
                        _buildStatRow('Open', '₹${widget.stock['open'] ?? 'N/A'}'),
                        _buildStatRow('Market Cap', widget.stock['marketCap'] ?? 'N/A'),
                        _buildStatRow('P/E Ratio', widget.stock['pe'] ?? 'N/A'),
                        const SizedBox(height: 28),

                        // Buy/Sell Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [positiveGreen, positiveGreen.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: positiveGreen.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _showBuySheet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'BUY',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(color: negativeRed.withOpacity(0.5), width: 2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: _showSellSheet,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: negativeRed,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'SELL',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}