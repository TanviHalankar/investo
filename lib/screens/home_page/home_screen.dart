import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:investo/chat_bot/chat_screen.dart';
import 'package:investo/screens/learning_screen.dart';
import 'package:investo/screens/portfolio_screen.dart';
import 'package:investo/screens/home_page/prediction_screen.dart';
import '../../api_service.dart';
import '../../model/stock_model.dart';
import '../../services/real_time_service.dart';
import '../../services/guide_service.dart';
import '../../services/user_data_service.dart';
import '../leader_board_screen.dart';
import '../profile_page/ProfilePage.dart';
import '../ipo_screen.dart';
import 'enhanced_chart.dart';
import '../../widgets/simple_tip_widget.dart';
import '../../widgets/owl_character.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  static HomeScreen fromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return HomeScreen(username: args is String ? args : 'User');
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _searchKey = GlobalKey();
  int _selectedBottomNavIndex = 0;
  int _selectedCarouselIndex = 0;

  List<Map<String, dynamic>> _filteredStocks = [];
  final List<Map<String, dynamic>> _watchlistStocks = [];
  bool _isSearching = false;

  // Real-time service
  final RealTimeService _realTimeService = RealTimeService();
  bool _isLoading = true;

  // Simple tip state
  bool _showSimpleTip = false;
  String _tipTitle = '';
  String _tipMessage = '';

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
    {'symbol': 'RELIANCE', 'name': 'RELIANCE INDUSTRIES', 'price': 2847.50, 'change': '+5.22%', 'isPositive': true, 'volume': '3.2M', 'high': '2,890.00', 'low': '2,820.00', 'open': '2,835.00', 'marketCap': '₹19.2L Cr', 'pe': '25.3'},
    {'symbol': 'TCS', 'name': 'TATA CONSULTANCY SERVICES', 'price': 3456.80, 'change': '+3.15%', 'isPositive': true, 'volume': '2.8M', 'high': '3,480.00', 'low': '3,420.00', 'open': '3,430.00', 'marketCap': '₹12.6L Cr', 'pe': '28.5'},
    {'symbol': 'INFY', 'name': 'INFOSYS LIMITED', 'price': 1567.30, 'change': '+2.89%', 'isPositive': true, 'volume': '4.1M', 'high': '1,580.00', 'low': '1,550.00', 'open': '1,555.00', 'marketCap': '₹6.5L Cr', 'pe': '26.8'},
    {'symbol': 'WIPRO', 'name': 'WIPRO LIMITED', 'price': 445.20, 'change': '-2.34%', 'isPositive': false, 'volume': '5.2M', 'high': '455.00', 'low': '442.00', 'open': '453.00', 'marketCap': '₹2.4L Cr', 'pe': '22.1'},
    {'symbol': 'TECHM', 'name': 'TECH MAHINDRA', 'price': 1023.45, 'change': '-1.78%', 'isPositive': false, 'volume': '2.9M', 'high': '1,042.00', 'low': '1,018.00', 'open': '1,038.00', 'marketCap': '₹1.0L Cr', 'pe': '18.4'},
    {'symbol': 'HDFC', 'name': 'HDFC BANK LIMITED', 'price': 1634.70, 'change': '+1.45%', 'isPositive': true, 'volume': '6.3M', 'high': '1,650.00', 'low': '1,620.00', 'open': '1,625.00', 'marketCap': '₹12.3L Cr', 'pe': '19.7'},
    {'symbol': 'ICICI', 'name': 'ICICI BANK LIMITED', 'price': 987.60, 'change': '-0.67%', 'isPositive': false, 'volume': '7.1M', 'high': '995.00', 'low': '982.00', 'open': '993.00', 'marketCap': '₹6.9L Cr', 'pe': '17.2'},
    {'symbol': 'ADANI', 'name': 'ADANI ENTERPRISES', 'price': 2156.40, 'change': '+4.23%', 'isPositive': true, 'volume': '4.8M', 'high': '2,180.00', 'low': '2,130.00', 'open': '2,140.00', 'marketCap': '₹2.5L Cr', 'pe': '35.6'},
    {'symbol': 'BAJAJ', 'name': 'BAJAJ FINANCE', 'price': 7834.20, 'change': '+2.11%', 'isPositive': true, 'volume': '1.4M', 'high': '7,890.00', 'low': '7,780.00', 'open': '7,800.00', 'marketCap': '₹4.8L Cr', 'pe': '32.4'},
    {'symbol': 'ITC', 'name': 'ITC LIMITED', 'price': 445.60, 'change': '+0.89%', 'isPositive': true, 'volume': '8.9M', 'high': '448.00', 'low': '442.00', 'open': '443.00', 'marketCap': '₹5.5L Cr', 'pe': '24.3'},
    {'symbol': 'HCLTECH', 'name': 'HCL TECHNOLOGIES', 'price': 1234.80, 'change': '-0.45%', 'isPositive': false, 'volume': '3.2M', 'high': '1,245.00', 'low': '1,228.00', 'open': '1,240.00', 'marketCap': '₹3.3L Cr', 'pe': '21.7'},
    {'symbol': 'BHARTI', 'name': 'BHARTI AIRTEL', 'price': 1567.90, 'change': '+2.34%', 'isPositive': true, 'volume': '4.5M', 'high': '1,580.00', 'low': '1,545.00', 'open': '1,552.00', 'marketCap': '₹9.2L Cr', 'pe': '42.8'},
    {'symbol': 'ASIAN', 'name': 'ASIAN PAINTS', 'price': 2945.30, 'change': '-1.23%', 'isPositive': false, 'volume': '1.8M', 'high': '2,982.00', 'low': '2,935.00', 'open': '2,975.00', 'marketCap': '₹2.8L Cr', 'pe': '56.2'},
    {'symbol': 'MARUTI', 'name': 'MARUTI SUZUKI INDIA', 'price': 11234.50, 'change': '+1.78%', 'isPositive': true, 'volume': '1.2M', 'high': '11,290.00', 'low': '11,180.00', 'open': '11,195.00', 'marketCap': '₹3.4L Cr', 'pe': '28.9'},
    {'symbol': 'TITAN', 'name': 'TITAN COMPANY', 'price': 3456.70, 'change': '+0.56%', 'isPositive': true, 'volume': '2.1M', 'high': '3,475.00', 'low': '3,438.00', 'open': '3,445.00', 'marketCap': '₹3.1L Cr', 'pe': '67.3'},
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

    // Load user-specific data including persisted watchlist
    _loadUserData().then((_) {
      _initRealTimeData();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredStocks = [];
      } else {
        GuideService().complete('home_welcome', award: 20);
        // Show next tip
        Future.delayed(const Duration(seconds: 1), () {
          GuideService().show(GuideStep(
            id: 'search_tip',
            title: 'Great searching! 🔍',
            message: 'Now tap on any stock to see detailed charts and try demo trading!',
          ));
        });
        _filteredStocks = allAvailableStocks.where((stock) {
          return (stock['symbol'] as String).toLowerCase().contains(query) ||
              (stock['name'] as String).toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      final userDataService = UserDataService.instance;
      final currentUser = userDataService.currentUser;

      if (currentUser != null) {
        print('Current user found: ${currentUser.username}');
        // Load user-specific preferences and settings
        final userPreferences = currentUser.preferences;
        final userPortfolio = currentUser.portfolio;
        final userSettings = currentUser.settings;

        // Load watchlist from user data
        final watchlist = userDataService.getWatchlist();

        print('Loaded user data for: ${currentUser.username}');
        print('User preferences: $userPreferences');
        print('User portfolio: $userPortfolio');
        print('User settings: $userSettings');
        print('Watchlist: $watchlist');

        // Update UI based on user data
        setState(() {
          _watchlistStocks.clear();
          _watchlistStocks.addAll(watchlist);
          print('Updated _watchlistStocks: ${_watchlistStocks.length} items');
        });

        // Show welcome tip if this is the first time
        if (watchlist.isEmpty) {
          Future.delayed(const Duration(seconds: 2), () {
            print('Showing welcome tip...');
            _showSimpleTipDialog(
              'Welcome! 🦉',
              'I\'m your Wise Owl guide! Try searching for stocks like RELIANCE or TCS, then add them to your watchlist!',
            );
          });
        }
      } else {
        print('No current user found!');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _showSimpleTipDialog(String title, String message) {
    setState(() {
      _tipTitle = title;
      _tipMessage = message;
      _showSimpleTip = true;
    });
  }

  void _hideSimpleTip() {
    setState(() {
      _showSimpleTip = false;
    });
  }

  Widget _buildPortfolioSummary() {
    final userDataService = UserDataService.instance;
    final portfolioSummary = userDataService.getPortfolioSummary();

    return GestureDetector(
      onTap: () {
        GuideService().show(GuideStep(
          id: 'portfolio_tip',
          title: 'Your Portfolio 💼',
          message: 'This shows your virtual money and investments. Start with ₹10,000 and try buying some stocks!',
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardDark, cardLight],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Portfolio Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 16, color: textSecondary),
                  tooltip: 'Show info',
                  onPressed: () {
                    GuideService().show(
                      GuideStep(
                        id: 'portfolio_summary_tip',
                        title: 'Portfolio Summary Info',
                        message: 'This shows virtual money, total invested, holdings, and total value.',
                      ),
                    );
                    Future.delayed(const Duration(seconds: 4), () {
                      GuideService().showNextTip(context);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Virtual Money',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '₹${portfolioSummary['virtualMoney'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Invested',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    Text(
                      '₹${portfolioSummary['totalInvested'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: accentOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Holdings: ${portfolioSummary['holdingsCount']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                Text(
                  'Total Value: ₹${portfolioSummary['totalValue'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: positiveGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _buyStock(Map<String, dynamic> stock, int quantity) async {
    final userDataService = UserDataService.instance;
    final price = (stock['price'] as num).toDouble();
    final success = await userDataService.buyStock(
        stock['symbol'],
        stock['name'],
        price,
        quantity
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully bought $quantity shares of ${stock['symbol']}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh user data
      _loadUserData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient funds to buy ${stock['symbol']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToWatchlist(Map<String, dynamic> stock) async {
    print('Adding ${stock['symbol']} to watchlist...');
    final userDataService = UserDataService.instance;
    final success = await userDataService.addToWatchlist(stock);

    print('Add to watchlist result: $success');
    if (success) {
      // Subscribe to real-time updates for this stock
      _realTimeService.subscribeToStock(stock['symbol']);
      setState(() {
        _watchlistStocks.add(stock);
        print('Added to local watchlist. Total items: ${_watchlistStocks.length}');
      });

      GuideService().show(GuideStep(
        id: 'watchlist_added',
        title: 'Added to Watchlist! 📋',
        message: "${stock['symbol']} added to your watchlist. Tap to view chart and trade!",
      ));
      Future.delayed(const Duration(seconds: 3), () => GuideService().hide());
    } else {
      print('Failed to add to watchlist');
      GuideService().show(GuideStep(
        id: 'watchlist_error',
        title: 'Oops! 🦉',
        message: "Failed to add ${stock['symbol']} to watchlist. Please try again.",
      ));
      Future.delayed(const Duration(seconds: 3), () => GuideService().hide());
    }
  }

  void _removeFromWatchlist(Map<String, dynamic> stock) async {
    final userDataService = UserDataService.instance;
    final success = await userDataService.removeFromWatchlist(stock['symbol']);

    if (success) {
      setState(() {
        _watchlistStocks.removeWhere((s) => s['symbol'] == stock['symbol']);
      });

      GuideService().show(GuideStep(
        id: 'watchlist_removed',
        title: 'Removed! 📋',
        message: "${stock['symbol']} removed from your watchlist.",
      ));
      Future.delayed(const Duration(seconds: 2), () => GuideService().hide());
    } else {
      GuideService().show(GuideStep(
        id: 'watchlist_remove_error',
        title: 'Oops! 🦉',
        message: "Failed to remove ${stock['symbol']} from watchlist.",
      ));
      Future.delayed(const Duration(seconds: 2), () => GuideService().hide());
    }
  }

  bool _isInWatchlist(String symbol) {
    final userDataService = UserDataService.instance;
    return userDataService.isInWatchlist(symbol);
  }

  void _initRealTimeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Connect to the real-time service
      _realTimeService.connect();

      // Get initial data
      final mockData = _realTimeService.getMockStockData();
      setState(() {
        allAvailableStocks = mockData;
      });

      // Listen for market updates
      _realTimeService.marketUpdates.listen((updatedStocks) {
        if (mounted) {
          setState(() {
            allAvailableStocks = updatedStocks;
          });
        }
      });

      // Listen for individual stock updates
      _realTimeService.stockUpdates.listen((stockUpdate) {
        if (mounted) {
          setState(() {
            final index = allAvailableStocks.indexWhere(
                    (stock) => stock['symbol'] == stockUpdate['symbol']
            );

            if (index != -1) {
              allAvailableStocks[index] = stockUpdate;
            }

            // Also update watchlist if needed
            final watchlistIndex = _watchlistStocks.indexWhere(
                    (stock) => stock['symbol'] == stockUpdate['symbol']
            );

            if (watchlistIndex != -1) {
              _watchlistStocks[watchlistIndex] = stockUpdate;
            }
          });
        }
      });
    } catch (e) {
      print('Error initializing real-time data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          SafeArea(
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
                              _buildPortfolioSummary(),
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
          // Owl chat AI overlay
          Positioned(
            right: 16,
            bottom: 24,
            child: OwlCoach(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
          ),
          // Tip bubble overlay
          if (_showSimpleTip)
            SimpleTipWidget(
              title: _tipTitle,
              message: _tipMessage,
              onClose: _hideSimpleTip,
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 16),
      decoration: const BoxDecoration(
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
                const Text(
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
            Row(
              children: [
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: cardDark,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.campaign_outlined, color: textSecondary, size: 24),
                    tooltip: 'View IPOs',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IpoScreen()));
                    },
                  ),
                ),
              ],
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
          key: _searchKey,
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
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 56, color: textTertiary),
                    SizedBox(height: 16),
                    Text(
                      'No stocks found',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
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
            ..._filteredStocks.map((stock) => _buildSearchResultCard(stock)),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> stock) {
    final bool inWatchlist = _isInWatchlist(stock['symbol']);

    return GestureDetector(
      onTap: () {
        GuideService().complete('open_stock_details', award: 30);
        _showStockDetails(stock);
      },
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
                gradient: inWatchlist ? null : const LinearGradient(
                  colors: [accentOrange, accentOrangeDim],
                ),
                color: inWatchlist ? cardLight : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: inWatchlist ? [] : [
                  BoxShadow(
                    color: accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
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
                  style: const TextStyle(
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
          SizedBox(
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
                          offset: const Offset(0, 4),
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
          SizedBox(
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
              GestureDetector(
                onTap: () {
                  GuideService().show(GuideStep(
                    id: 'watchlist_tip',
                    title: 'Your Watchlist 📋',
                    message: 'Add stocks here to track them easily! Tap the bookmark icon on any stock to add it.',
                  ));
                },
                child: const Row(
                  children: [
                    Text(
                      'Your Watchlist',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: textSecondary,
                    ),
                  ],
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
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.bookmark_border_rounded, size: 56, color: textTertiary),
                    SizedBox(height: 16),
                    Text(
                      'No stocks in watchlist',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
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
            ..._watchlistStocks.map((stock) => _buildWatchlistCard(stock)),
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
                  decoration: const BoxDecoration(
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
      decoration: const BoxDecoration(
        color: cardDark,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomNavIndex = index;
          });

          // Show tips for different sections
          switch (index) {
            case 0:
            // Home - stay on current screen
              GuideService().show(GuideStep(
                id: 'home_nav_tip',
                title: 'Home Sweet Home 🏠',
                message: 'You\'re on the main screen! Search stocks, check your portfolio, and manage your watchlist here.',
              ));
              break;
            case 1:
              GuideService().show(GuideStep(
                id: 'portfolio_nav_tip',
                title: 'Portfolio Time! 💼',
                message: 'Let\'s check your investments! This shows all your stock holdings and trading history.',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PortfolioScreen()),
              );
              break;
            case 2:
              GuideService().show(GuideStep(
                id: 'learn_nav_tip',
                title: 'Learning Hub 📚',
                message: 'Ready to learn? This section has tutorials, articles, and quizzes to improve your trading skills!',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LearningScreen(username: widget.username)),
              );
              break;
            case 3:
              GuideService().show(GuideStep(
                id: 'leaderboard_nav_tip',
                title: 'Competition Time! 🏆',
                message: 'See how you rank against other traders! Compete and climb the leaderboard!',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderBoardScreen()),
              );
              break;
            case 4:
              GuideService().show(GuideStep(
                id: 'profile_nav_tip',
                title: 'Your Profile 👤',
                message: 'Manage your account settings, view your stats, and customize your trading experience!',
              ));
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Profilepage()),
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
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
            icon: Icon(Icons.person_rounded, size: 26),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// CoachOverlay widget - assuming this is defined elsewhere, but adding a placeholder if needed

class OwlCoach extends StatelessWidget {
  final VoidCallback onTap;

  const OwlCoach({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF9500), Color(0xFFCC7700)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9500).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: OwlCharacter(size: 56.0),
        ),
      ),
    );
  }
}