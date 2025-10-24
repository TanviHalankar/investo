import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class PracticeScreen extends StatefulWidget {
  final String username;

  const PracticeScreen({super.key, required this.username});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedTabIndex = 0;
  String selectedStock = 'AAPL';
  double virtualBalance = 10000.0;
  double portfolioValue = 12450.0;
  double totalPnL = 2450.0;

  // Platform-aware properties
  bool get isWeb => kIsWeb;
  double get maxWidth => isWeb ? 900 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;
  double get cardBorderRadius => isWeb ? 16 : 20;

  final List<String> tabs = ['Portfolio', 'Trade', 'Watchlist', 'History'];

  final List<Stock> watchlistStocks = [
    Stock(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      price: 175.43,
      change: 2.34,
      changePercent: 1.35,
      volume: '45.2M',
      marketCap: '2.8T',
    ),
    Stock(
      symbol: 'GOOGL',
      name: 'Alphabet Inc.',
      price: 142.87,
      change: -1.23,
      changePercent: -0.85,
      volume: '28.7M',
      marketCap: '1.8T',
    ),
    Stock(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      price: 384.52,
      change: 5.67,
      changePercent: 1.5,
      volume: '32.1M',
      marketCap: '2.9T',
    ),
    Stock(
      symbol: 'TSLA',
      name: 'Tesla Inc.',
      price: 248.91,
      change: -8.45,
      changePercent: -3.28,
      volume: '67.8M',
      marketCap: '790B',
    ),
    Stock(
      symbol: 'NVDA',
      name: 'NVIDIA Corp.',
      price: 892.31,
      change: 15.67,
      changePercent: 1.79,
      volume: '41.3M',
      marketCap: '2.2T',
    ),
  ];

  final List<Position> portfolioPositions = [
    Position(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      shares: 10,
      avgPrice: 165.50,
      currentPrice: 175.43,
      totalValue: 1754.30,
      pnl: 99.30,
      pnlPercent: 6.0,
    ),
    Position(
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      shares: 8,
      avgPrice: 370.25,
      currentPrice: 384.52,
      totalValue: 3076.16,
      pnl: 114.16,
      pnlPercent: 3.86,
    ),
    Position(
      symbol: 'GOOGL',
      name: 'Alphabet Inc.',
      shares: 15,
      avgPrice: 145.80,
      currentPrice: 142.87,
      totalValue: 2143.05,
      pnl: -43.95,
      pnlPercent: -2.01,
    ),
  ];

  final List<Trade> tradeHistory = [
    Trade(
      symbol: 'AAPL',
      type: 'BUY',
      shares: 5,
      price: 172.30,
      date: '2024-08-01',
      time: '10:30 AM',
      total: 861.50,
    ),
    Trade(
      symbol: 'TSLA',
      type: 'SELL',
      shares: 3,
      price: 255.67,
      date: '2024-07-30',
      time: '2:15 PM',
      total: 767.01,
    ),
    Trade(
      symbol: 'NVDA',
      type: 'BUY',
      shares: 2,
      price: 876.45,
      date: '2024-07-28',
      time: '11:45 AM',
      total: 1752.90,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF533483),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Tab navigation
                  _buildTabNavigation(),

                  // Main content
                  Expanded(
                    child: IndexedStack(
                      index: selectedTabIndex,
                      children: [
                        _buildPortfolioTab(),
                        _buildTradeTab(),
                        _buildWatchlistTab(),
                        _buildHistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: Row(
        children: [
          // Back button
          MouseRegion(
            cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: isWeb ? 18 : 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practice Trading',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 22 : 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Virtual Portfolio: \$${portfolioValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF00d4aa),
                    fontSize: isWeb ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // P&L indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: totalPnL >= 0
                  ? const Color(0xFF00d4aa).withOpacity(0.2)
                  : const Color(0xFFe17055).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: totalPnL >= 0
                    ? const Color(0xFF00d4aa)
                    : const Color(0xFFe17055),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  totalPnL >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: totalPnL >= 0
                      ? const Color(0xFF00d4aa)
                      : const Color(0xFFe17055),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${totalPnL >= 0 ? '+' : ''}\$${totalPnL.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: totalPnL >= 0
                        ? const Color(0xFF00d4aa)
                        : const Color(0xFFe17055),
                    fontSize: isWeb ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          String tab = entry.value;
          bool isSelected = selectedTabIndex == index;

          return Expanded(
            child: MouseRegion(
              cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTabIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: isWeb ? 10 : 12,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00d4aa).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF00d4aa).withOpacity(0.5))
                        : null,
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF00d4aa)
                          : Colors.white.withOpacity(0.7),
                      fontSize: isWeb ? 13 : 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Portfolio summary card
              _buildPortfolioSummaryCard(),
              const SizedBox(height: 20),

              // Holdings section
              Text(
                'Your Holdings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 18 : 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Holdings list
              ...portfolioPositions.map((position) => _buildPositionCard(position)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSummaryCard() {
    double dayChange = 145.67;
    double dayChangePercent = 1.18;

    return ClipRRect(
      borderRadius: BorderRadius.circular(cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.all(isWeb ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portfolio Value',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isWeb ? 14 : 15,
                        ),
                      ),
                      Text(
                        '\$${portfolioValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 28 : 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: totalPnL >= 0
                            ? [const Color(0xFF00d4aa), const Color(0xFF00b894)]
                            : [const Color(0xFFe17055), const Color(0xFFd63031)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      totalPnL >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: isWeb ? 24 : 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      'Total P&L',
                      '${totalPnL >= 0 ? '+' : ''}\$${totalPnL.toStringAsFixed(2)}',
                      totalPnL >= 0 ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Day Change',
                      '${dayChange >= 0 ? '+' : ''}\$${dayChange.toStringAsFixed(2)}',
                      dayChange >= 0 ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildSummaryItem(
                      'Cash Balance',
                      '\$${virtualBalance.toStringAsFixed(2)}',
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: isWeb ? 12 : 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isWeb ? 16 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionCard(Position position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: EdgeInsets.all(isWeb ? 16 : 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Stock info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            position.symbol,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 16 : 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${position.shares} shares',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isWeb ? 10 : 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        position.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: isWeb ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${position.currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWeb ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Avg: \$${position.avgPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: isWeb ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // P&L info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${position.pnl >= 0 ? '+' : ''}\$${position.pnl.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: position.pnl >= 0
                              ? const Color(0xFF00d4aa)
                              : const Color(0xFFe17055),
                          fontSize: isWeb ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${position.pnlPercent >= 0 ? '+' : ''}${position.pnlPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: position.pnl >= 0
                              ? const Color(0xFF00d4aa)
                              : const Color(0xFFe17055),
                          fontSize: isWeb ? 11 : 12,
                        ),
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

  Widget _buildTradeTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Quick trade card
              _buildQuickTradeCard(),
              const SizedBox(height: 20),

              // Popular stocks for trading
              _buildPopularStocksSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTradeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.all(isWeb ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: const Color(0xFF00d4aa),
                    size: isWeb ? 24 : 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Trade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 20 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stock selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedStock,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 18 : 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            watchlistStocks.firstWhere((s) => s.symbol == selectedStock).name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isWeb ? 13 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${watchlistStocks.firstWhere((s) => s.symbol == selectedStock).price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWeb ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${watchlistStocks.firstWhere((s) => s.symbol == selectedStock).change >= 0 ? '+' : ''}${watchlistStocks.firstWhere((s) => s.symbol == selectedStock).changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: watchlistStocks.firstWhere((s) => s.symbol == selectedStock).change >= 0
                                ? const Color(0xFF00d4aa)
                                : const Color(0xFFe17055),
                            fontSize: isWeb ? 13 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Buy/Sell buttons
              Row(
                children: [
                  Expanded(
                    child: _buildTradeButton('BUY', const Color(0xFF00d4aa), () {
                      _showTradeDialog('BUY');
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTradeButton('SELL', const Color(0xFFe17055), () {
                      _showTradeDialog('SELL');
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeButton(String text, Color color, VoidCallback onPressed) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isWeb ? 14 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isWeb ? 16 : 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularStocksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular for Trading',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWeb ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        ...watchlistStocks.take(3).map((stock) => _buildPopularStockCard(stock)),
      ],
    );
  }

  Widget _buildPopularStockCard(Stock stock) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStock = stock.symbol;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(isWeb ? 16 : 14),
          decoration: BoxDecoration(
            color: selectedStock == stock.symbol
                ? const Color(0xFF00d4aa).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedStock == stock.symbol
                  ? const Color(0xFF00d4aa).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      stock.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: isWeb ? 12 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${stock.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${stock.change >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: stock.change >= 0
                          ? const Color(0xFF00d4aa)
                          : const Color(0xFFe17055),
                      fontSize: isWeb ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 20 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MouseRegion(
                    cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: GestureDetector(
                      onTap: () {
                        // Add new stock to watchlist
                        _showAddStockDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00d4aa).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF00d4aa)),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF00d4aa),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Market status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00d4aa).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00d4aa).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00d4aa),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Market Open',
                      style: TextStyle(
                        color: const Color(0xFF00d4aa),
                        fontSize: isWeb ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Watchlist stocks
              ...watchlistStocks.map((stock) => _buildWatchlistStockCard(stock)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchlistStockCard(Stock stock) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          _showStockDetailsDialog(stock);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: EdgeInsets.all(isWeb ? 18 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    // Stock info
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stock.symbol,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWeb ? 18 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                stock.change >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: stock.change >= 0
                                    ? const Color(0xFF00d4aa)
                                    : const Color(0xFFe17055),
                                size: 16,
                              ),
                            ],
                          ),
                          Text(
                            stock.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: isWeb ? 13 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Vol: ${stock.volume}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: isWeb ? 11 : 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Cap: ${stock.marketCap}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: isWeb ? 11 : 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price and change
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\${stock.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 18 : 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: stock.change >= 0
                                  ? const Color(0xFF00d4aa).withOpacity(0.2)
                                  : const Color(0xFFe17055).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${stock.change >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: stock.change >= 0
                                    ? const Color(0xFF00d4aa)
                                    : const Color(0xFFe17055),
                                fontSize: isWeb ? 12 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stock.change >= 0 ? '+' : ''}\${stock.change.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: stock.change >= 0
                                  ? const Color(0xFF00d4aa)
                                  : const Color(0xFFe17055),
                              fontSize: isWeb ? 12 : 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              Text(
                'Trading History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 20 : 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Trade history list
              ...tradeHistory.map((trade) => _buildTradeHistoryCard(trade)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTradeHistoryCard(Trade trade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: EdgeInsets.all(isWeb ? 16 : 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                // Trade type indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: trade.type == 'BUY'
                        ? const Color(0xFF00d4aa).withOpacity(0.2)
                        : const Color(0xFFe17055).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    trade.type == 'BUY' ? Icons.add : Icons.remove,
                    color: trade.type == 'BUY'
                        ? const Color(0xFF00d4aa)
                        : const Color(0xFFe17055),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                // Trade details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            trade.type,
                            style: TextStyle(
                              color: trade.type == 'BUY'
                                  ? const Color(0xFF00d4aa)
                                  : const Color(0xFFe17055),
                              fontSize: isWeb ? 14 : 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            trade.symbol,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 14 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${trade.shares} shares at \${trade.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isWeb ? 12 : 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date, time and total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\${trade.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${trade.date} ${trade.time}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isWeb ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTradeDialog(String tradeType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$tradeType $selectedStock',
          style: TextStyle(
            color: tradeType == 'BUY' ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Price: \${watchlistStocks.firstWhere((s) => s.symbol == selectedStock).price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Number of Shares',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: tradeType == 'BUY' ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tradeType == 'BUY' ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _showTradeConfirmation(tradeType);
            },
            child: Text(
              'Place Order',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeConfirmation(String tradeType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: const Color(0xFF00d4aa),
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Order Placed!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Your $tradeType order for $selectedStock has been placed successfully.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4aa),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showStockDetailsDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${stock.symbol} - ${stock.name}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: \${stock.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Change: ${stock.change >= 0 ? '+' : ''}\${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                color: stock.change >= 0 ? const Color(0xFF00d4aa) : const Color(0xFFe17055),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Volume: ${stock.volume}',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Market Cap: ${stock.marketCap}',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4aa),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedStock = stock.symbol;
                selectedTabIndex = 1; // Switch to trade tab
              });
            },
            child: const Text(
              'Trade',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add to Watchlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Stock Symbol (e.g., AAPL)',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00d4aa)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4aa),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Add stock to watchlist logic here
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Data models
class Stock {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final String volume;
  final String marketCap;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
  });
}

class Position {
  final String symbol;
  final String name;
  final int shares;
  final double avgPrice;
  final double currentPrice;
  final double totalValue;
  final double pnl;
  final double pnlPercent;

  Position({
    required this.symbol,
    required this.name,
    required this.shares,
    required this.avgPrice,
    required this.currentPrice,
    required this.totalValue,
    required this.pnl,
    required this.pnlPercent,
  });
}

class Trade {
  final String symbol;
  final String type;
  final int shares;
  final double price;
  final String date;
  final String time;
  final double total;

  Trade({
    required this.symbol,
    required this.type,
    required this.shares,
    required this.price,
    required this.date,
    required this.time,
    required this.total,
  });
}