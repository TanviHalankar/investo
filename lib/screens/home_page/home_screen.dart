import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:investo/screens/learning_screen.dart';
import 'package:investo/screens/portfolio_screen.dart';
import 'package:investo/screens/home_page/prediction_screen.dart';
import '../../api_service.dart';
import '../leader_board_screen.dart';
import '../practice _trading.dart';
import 'enhanced_chart.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 0;
  int _selectedCarouselIndex = 0;

  List<Map<String, dynamic>> _filteredStocks = [];
  List<Map<String, dynamic>> _watchlistStocks = [];
  bool _isSearching = false;

  // Modern dark color scheme with orange accents
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb;

  double get maxWidth => isWeb ? 600 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;

  List<String> carouselCategories = [
    'Top Gainers',
    'Top Losers',
    'Most Active',
    'Trending',
    'Market Cap'
  ];

  // All available stocks in the market
  List<Map<String, dynamic>> allAvailableStocks = [
    {'symbol': 'RELIANCE', 'name': 'RELIANCE INDUSTRIES', 'price': '2,847.50', 'change': '+5.22%', 'isPositive': true, 'volume': '3.2M', 'high': '2,890.00', 'low': '2,820.00', 'open': '2,835.00', 'marketCap': '₹19.2L Cr', 'pe': '25.3'},
    {'symbol': 'TCS', 'name': 'TATA CONSULTANCY SERVICES', 'price': '3,456.80', 'change': '+3.15%', 'isPositive': true, 'volume': '2.8M', 'high': '3,480.00', 'low': '3,420.00', 'open': '3,430.00', 'marketCap': '₹12.6L Cr', 'pe': '28.5'},
    {'symbol': 'INFY', 'name': 'INFOSYS LIMITED', 'price': '1,567.30', 'change': '+2.89%', 'isPositive': true, 'volume': '4.1M', 'high': '1,580.00', 'low': '1,550.00', 'open': '1,555.00', 'marketCap': '₹6.5L Cr', 'pe': '26.8'},
    {'symbol': 'WIPRO', 'name': 'WIPRO LIMITED', 'price': '445.20', 'change': '-2.34%', 'isPositive': false, 'volume': '5.2M', 'high': '455.00', 'low': '442.00', 'open': '453.00', 'marketCap': '₹2.4L Cr', 'pe': '22.1'},
    {'symbol': 'TECHM', 'name': 'TECH MAHINDRA', 'price': '1,023.45', 'change': '-1.78%', 'isPositive': false, 'volume': '2.9M', 'high': '1,042.00', 'low': '1,018.00', 'open': '1,038.00', 'marketCap': '₹1.0L Cr', 'pe': '18.4'},
    {'symbol': 'HDFC', 'name': 'HDFC BANK LIMITED', 'price': '1,634.70', 'change': '+1.45%', 'isPositive': true, 'volume': '6.3M', 'high': '1,650.00', 'low': '1,620.00', 'open': '1,625.00', 'marketCap': '₹12.3L Cr', 'pe': '19.7'},
    {'symbol': 'ICICI', 'name': 'ICICI BANK LIMITED', 'price': '987.60', 'change': '-0.67%', 'isPositive': false, 'volume': '7.1M', 'high': '995.00', 'low': '982.00', 'open': '993.00', 'marketCap': '₹6.9L Cr', 'pe': '17.2'},
    {'symbol': 'ADANI', 'name': 'ADANI ENTERPRISES', 'price': '2,156.40', 'change': '+4.23%', 'isPositive': true, 'volume': '4.8M', 'high': '2,180.00', 'low': '2,130.00', 'open': '2,140.00', 'marketCap': '₹2.5L Cr', 'pe': '35.6'},
    {'symbol': 'BAJAJ', 'name': 'BAJAJ FINANCE', 'price': '7,834.20', 'change': '+2.11%', 'isPositive': true, 'volume': '1.4M', 'high': '7,890.00', 'low': '7,780.00', 'open': '7,800.00', 'marketCap': '₹4.8L Cr', 'pe': '32.4'},
    {'symbol': 'ITC', 'name': 'ITC LIMITED', 'price': '445.60', 'change': '+0.89%', 'isPositive': true, 'volume': '8.9M', 'high': '448.00', 'low': '442.00', 'open': '443.00', 'marketCap': '₹5.5L Cr', 'pe': '24.3'},
    {'symbol': 'HCLTECH', 'name': 'HCL TECHNOLOGIES', 'price': '1,234.80', 'change': '-0.45%', 'isPositive': false, 'volume': '3.2M', 'high': '1,245.00', 'low': '1,228.00', 'open': '1,240.00', 'marketCap': '₹3.3L Cr', 'pe': '21.7'},
    {'symbol': 'BHARTI', 'name': 'BHARTI AIRTEL', 'price': '1,567.90', 'change': '+2.34%', 'isPositive': true, 'volume': '4.5M', 'high': '1,580.00', 'low': '1,545.00', 'open': '1,552.00', 'marketCap': '₹9.2L Cr', 'pe': '42.8'},
    {'symbol': 'ASIAN', 'name': 'ASIAN PAINTS', 'price': '2,945.30', 'change': '-1.23%', 'isPositive': false, 'volume': '1.8M', 'high': '2,982.00', 'low': '2,935.00', 'open': '2,975.00', 'marketCap': '₹2.8L Cr', 'pe': '56.2'},
    {'symbol': 'MARUTI', 'name': 'MARUTI SUZUKI INDIA', 'price': '11,234.50', 'change': '+1.78%', 'isPositive': true, 'volume': '1.2M', 'high': '11,290.00', 'low': '11,180.00', 'open': '11,195.00', 'marketCap': '₹3.4L Cr', 'pe': '28.9'},
    {'symbol': 'TITAN', 'name': 'TITAN COMPANY', 'price': '3,456.70', 'change': '+0.56%', 'isPositive': true, 'volume': '2.1M', 'high': '3,475.00', 'low': '3,438.00', 'open': '3,445.00', 'marketCap': '₹3.1L Cr', 'pe': '67.3'},
  ];

  Map<String, List<Map<String, dynamic>>> get categoryStocks {
    return {
      'Top Gainers': allAvailableStocks.where((s) => s['isPositive'] == true).take(5).toList(),
      'Top Losers': allAvailableStocks.where((s) => s['isPositive'] == false).take(5).toList(),
      'Most Active': allAvailableStocks.take(5).toList(),
      'Trending': allAvailableStocks.skip(5).take(5).toList(),
      'Market Cap': allAvailableStocks.take(5).toList(),
    };
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
    _filteredStocks = [];

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredStocks = [];
      } else {
        _filteredStocks = allAvailableStocks.where((stock) {
          return stock['symbol'].toLowerCase().contains(query) ||
              stock['name'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _addToWatchlist(Map<String, dynamic> stock) {
    setState(() {
      // Check if already in watchlist
      bool alreadyExists = _watchlistStocks.any((s) => s['symbol'] == stock['symbol']);
      if (!alreadyExists) {
        _watchlistStocks.add(stock);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock['symbol']} added to watchlist'),
            backgroundColor: positiveGreen,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock['symbol']} is already in watchlist'),
            backgroundColor: accentOrange,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  void _removeFromWatchlist(Map<String, dynamic> stock) {
    setState(() {
      _watchlistStocks.removeWhere((s) => s['symbol'] == stock['symbol']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock['symbol']} removed from watchlist'),
          backgroundColor: negativeRed,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  bool _isInWatchlist(String symbol) {
    return _watchlistStocks.any((s) => s['symbol'] == symbol);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _showStockDetails(Map<String, dynamic> stock) {
    final bool inWatchlist = _isInWatchlist(stock['symbol']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedStockDetailsSheet(
        stock: stock,
        isInWatchlist: inWatchlist,
        onAddToWatchlist: _addToWatchlist,
        onRemoveFromWatchlist: _removeFromWatchlist,
      ),
    );
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => DraggableScrollableSheet(
    //     initialChildSize: 0.7,
    //     minChildSize: 0.5,
    //     maxChildSize: 0.95,
    //     builder: (context, scrollController) {
    //       return Container(
    //         decoration: BoxDecoration(
    //           color: cardDark,
    //           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    //         ),
    //         child: Column(
    //           children: [
    //             Container(
    //               margin: const EdgeInsets.symmetric(vertical: 14),
    //               width: 40,
    //               height: 5,
    //               decoration: BoxDecoration(
    //                 color: borderColor,
    //                 borderRadius: BorderRadius.circular(3),
    //               ),
    //             ),
    //             Expanded(
    //               child: SingleChildScrollView(
    //                 controller: scrollController,
    //                 physics: const BouncingScrollPhysics(),
    //                 child: Padding(
    //                   padding: const EdgeInsets.all(24),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         children: [
    //                           Expanded(
    //                             child: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Text(
    //                                   stock['symbol'],
    //                                   style: const TextStyle(
    //                                     color: textPrimary,
    //                                     fontSize: 32,
    //                                     fontWeight: FontWeight.w700,
    //                                     letterSpacing: -1,
    //                                   ),
    //                                 ),
    //                                 const SizedBox(height: 6),
    //                                 Text(
    //                                   stock['name'] ?? stock['symbol'],
    //                                   style: const TextStyle(
    //                                     color: textSecondary,
    //                                     fontSize: 15,
    //                                     fontWeight: FontWeight.w400,
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           Container(
    //                             decoration: BoxDecoration(
    //                               color: cardLight,
    //                               shape: BoxShape.circle,
    //                             ),
    //                             child: IconButton(
    //                               onPressed: () => Navigator.pop(context),
    //                               icon: const Icon(Icons.close_rounded, color: textSecondary),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       const SizedBox(height: 28),
    //                       Container(
    //                         padding: const EdgeInsets.all(24),
    //                         decoration: BoxDecoration(
    //                           color: cardLight,
    //                           borderRadius: BorderRadius.circular(20),
    //                         ),
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             const Text(
    //                               'Current Price',
    //                               style: TextStyle(
    //                                 color: textTertiary,
    //                                 fontSize: 13,
    //                                 fontWeight: FontWeight.w500,
    //                                 letterSpacing: 0.5,
    //                               ),
    //                             ),
    //                             const SizedBox(height: 12),
    //                             Row(
    //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                               crossAxisAlignment: CrossAxisAlignment.end,
    //                               children: [
    //                                 Text(
    //                                   '₹${stock['price']}',
    //                                   style: const TextStyle(
    //                                     color: textPrimary,
    //                                     fontSize: 40,
    //                                     fontWeight: FontWeight.w700,
    //                                     letterSpacing: -1.5,
    //                                     height: 1.0,
    //                                   ),
    //                                 ),
    //                                 Container(
    //                                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    //                                   decoration: BoxDecoration(
    //                                     color: stock['isPositive'] ? positiveGreen.withOpacity(0.15) : negativeRed.withOpacity(0.15),
    //                                     borderRadius: BorderRadius.circular(12),
    //                                   ),
    //                                   child: Text(
    //                                     stock['change'],
    //                                     style: TextStyle(
    //                                       color: stock['isPositive'] ? positiveGreen : negativeRed,
    //                                       fontSize: 17,
    //                                       fontWeight: FontWeight.w700,
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(height: 24),
    //                       Container(
    //                         height: 220,
    //                         decoration: BoxDecoration(
    //                           color: cardLight,
    //                           borderRadius: BorderRadius.circular(20),
    //                         ),
    //                         child: Center(
    //                           child: Column(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: [
    //                               Icon(Icons.show_chart_rounded, color: accentOrange, size: 56),
    //                               SizedBox(height: 14),
    //                               Text(
    //                                 'Stock Chart',
    //                                 style: TextStyle(
    //                                   color: textSecondary,
    //                                   fontSize: 17,
    //                                   fontWeight: FontWeight.w500,
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                       const SizedBox(height: 28),
    //                       const Text(
    //                         'Key Statistics',
    //                         style: TextStyle(
    //                           color: textPrimary,
    //                           fontSize: 20,
    //                           fontWeight: FontWeight.w700,
    //                           letterSpacing: -0.5,
    //                         ),
    //                       ),
    //                       const SizedBox(height: 18),
    //                       _buildStatRow('Volume', stock['volume'] ?? 'N/A'),
    //                       _buildStatRow('Day High', '₹${stock['high'] ?? 'N/A'}'),
    //                       _buildStatRow('Day Low', '₹${stock['low'] ?? 'N/A'}'),
    //                       _buildStatRow('Open', '₹${stock['open'] ?? 'N/A'}'),
    //                       _buildStatRow('Market Cap', stock['marketCap'] ?? 'N/A'),
    //                       _buildStatRow('P/E Ratio', stock['pe'] ?? 'N/A'),
    //                       const SizedBox(height: 28),
    //                       Row(
    //                         children: [
    //                           Expanded(
    //                             child: Container(
    //                               height: 56,
    //                               decoration: BoxDecoration(
    //                                 gradient: LinearGradient(
    //                                   colors: [accentOrange, accentOrangeDim],
    //                                 ),
    //                                 borderRadius: BorderRadius.circular(16),
    //                                 boxShadow: [
    //                                   BoxShadow(
    //                                     color: accentOrange.withOpacity(0.3),
    //                                     blurRadius: 12,
    //                                     offset: Offset(0, 4),
    //                                   ),
    //                                 ],
    //                               ),
    //                               child: ElevatedButton(
    //                                 onPressed: () {},
    //                                 style: ElevatedButton.styleFrom(
    //                                   backgroundColor: Colors.transparent,
    //                                   foregroundColor: darkBg,
    //                                   elevation: 0,
    //                                   shadowColor: Colors.transparent,
    //                                   shape: RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(16),
    //                                   ),
    //                                 ),
    //                                 child: const Text(
    //                                   'BUY',
    //                                   style: TextStyle(
    //                                     fontSize: 17,
    //                                     fontWeight: FontWeight.w700,
    //                                     letterSpacing: 1,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                           const SizedBox(width: 14),
    //                           Expanded(
    //                             child: Container(
    //                               height: 56,
    //                               decoration: BoxDecoration(
    //                                 border: Border.all(color: negativeRed.withOpacity(0.5), width: 2),
    //                                 borderRadius: BorderRadius.circular(16),
    //                               ),
    //                               child: ElevatedButton(
    //                                 onPressed: () {},
    //                                 style: ElevatedButton.styleFrom(
    //                                   backgroundColor: Colors.transparent,
    //                                   foregroundColor: negativeRed,
    //                                   elevation: 0,
    //                                   shadowColor: Colors.transparent,
    //                                   shape: RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(16),
    //                                   ),
    //                                 ),
    //                                 child: const Text(
    //                                   'SELL',
    //                                   style: TextStyle(
    //                                     fontSize: 17,
    //                                     fontWeight: FontWeight.w700,
    //                                     letterSpacing: 1,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       const SizedBox(height: 50),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        if (_isSearching) ...[
                          const SizedBox(height: 28),
                          _buildSearchResults(),
                        ] else ...[
                          const SizedBox(height: 28),
                          _buildCarouselSection(),
                          const SizedBox(height: 28),
                          _buildWatchlistSection(),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 16),
      decoration: BoxDecoration(
        color: darkBg,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: TextStyle(
                    fontSize: 14,
                    color: textTertiary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: cardDark,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: textSecondary, size: 26),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: _searchController.text.isNotEmpty
                ? Border.all(color: accentOrange.withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search stocks, ETFs...',
              hintStyle: const TextStyle(
                color: textTertiary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: textSecondary, size: 24),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () {
                  _searchController.clear();
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results (${_filteredStocks.length})',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          if (_filteredStocks.isEmpty)
            Container(
              padding: const EdgeInsets.all(50),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      'No stocks found',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredStocks.map((stock) => _buildSearchResultCard(stock)).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> stock) {
    final bool inWatchlist = _isInWatchlist(stock['symbol']);

    return GestureDetector(
      onTap: () => _showStockDetails(stock),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock['symbol'],
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stock['name'],
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '₹${stock['price']}',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: stock['isPositive'] ? positiveGreen.withOpacity(0.15) : negativeRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stock['change'],
                          style: TextStyle(
                            color: stock['isPositive'] ? positiveGreen : negativeRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: inWatchlist ? null : LinearGradient(
                  colors: [accentOrange, accentOrangeDim],
                ),
                color: inWatchlist ? cardLight : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: inWatchlist ? [] : [
                  BoxShadow(
                    color: accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (inWatchlist) {
                    _removeFromWatchlist(stock);
                  } else {
                    _addToWatchlist(stock);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: inWatchlist ? textSecondary : darkBg,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  inWatchlist ? 'Added' : 'Add',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: carouselCategories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCarouselIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCarouselIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? accentOrange : cardDark,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ] : [],
                    ),
                    child: Center(
                      child: Text(
                        carouselCategories[index],
                        style: TextStyle(
                          color: isSelected ? darkBg : textSecondary,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: categoryStocks[carouselCategories[_selectedCarouselIndex]]?.length ?? 0,
              itemBuilder: (context, index) {
                final stock = categoryStocks[carouselCategories[_selectedCarouselIndex]]![index];
                return GestureDetector(
                  onTap: () => _showStockDetails(stock),
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stock['symbol'],
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Icon(
                              stock['isPositive'] ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: stock['isPositive'] ? positiveGreen : negativeRed,
                              size: 24,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${stock['price']}',
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              stock['change'],
                              style: TextStyle(
                                color: stock['isPositive'] ? positiveGreen : negativeRed,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Watchlist',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_watchlistStocks.isEmpty)
            Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 56, color: textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      'No stocks in watchlist',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search and add stocks to track them',
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._watchlistStocks.map((stock) => _buildWatchlistCard(stock)).toList(),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(Map<String, dynamic> stock) {
    return GestureDetector(
      onTap: () => _showStockDetails(stock),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock['symbol'],
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stock['name'],
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    icon: const Icon(Icons.star_rounded, color: accentOrange),
                    onPressed: () => _removeFromWatchlist(stock),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${stock['price']}',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: stock['isPositive'] ? positiveGreen.withOpacity(0.15) : negativeRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        stock['change'],
                        style: TextStyle(
                          color: stock['isPositive'] ? positiveGreen : negativeRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  stock['isPositive'] ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  color: stock['isPositive'] ? positiveGreen : negativeRed,
                  size: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });
          switch (index) {
            case 0:
            // Home
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PortfolioScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LearningScreen(username: widget.username)),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderBoardScreen()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PracticeScreen(username: widget.username)),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardDark,
        selectedItemColor: accentOrange,
        unselectedItemColor: textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded, size: 26),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded, size: 26),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded, size: 26),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded, size: 26),
            label: 'Practice',
          ),
        ],
      ),
    );
  }
}