import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class UserDataService {
  static const String _currentUserKey = 'current_user';
  static const String _userDataPrefix = 'user_data_';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _lastActiveUserKey = 'last_active_user';

  static UserDataService? _instance;
  static UserDataService get instance => _instance ??= UserDataService._();
  
  UserDataService._();

  SharedPreferences? _prefs;
  UserModel? _currentUser;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCurrentUser();
  }

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Save user data (user-specific storage)
  Future<bool> saveUserData(UserModel user) async {
    if (_prefs == null) await init();
    
    try {
      // Save user data with user-specific key
      final userDataKey = '$_userDataPrefix${user.userId}';
      final userDataJson = jsonEncode(user.toJson());
      
      // Save current user data
      final currentUserJson = jsonEncode(user.toJson());
      
      // Save all data atomically
      final success = await _prefs!.setString(userDataKey, userDataJson) &&
                     await _prefs!.setString(_currentUserKey, currentUserJson) &&
                     await _prefs!.setBool(_isLoggedInKey, true) &&
                     await _prefs!.setString(_lastActiveUserKey, user.userId);
      
      if (success) {
        _currentUser = user;
      }
      
      return success;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    if (_prefs == null) await init();
    
    try {
      final currentUserJson = _prefs!.getString(_currentUserKey);
      if (currentUserJson != null) {
        final userData = jsonDecode(currentUserJson);
        _currentUser = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error loading current user: $e');
      _currentUser = null;
    }
  }

  // Get user data by user ID
  Future<UserModel?> getUserData(String userId) async {
    if (_prefs == null) await init();
    
    try {
      final userDataKey = '$_userDataPrefix$userId';
      final userDataJson = _prefs!.getString(userDataKey);
      
      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error getting user data for $userId: $e');
    }
    
    return null;
  }

  // Update current user data
  Future<bool> updateCurrentUser(UserModel updatedUser) async {
    return await saveUserData(updatedUser);
  }

  // Update specific user preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return false;
    
    final updatedUser = _currentUser!.copyWith(
      preferences: {..._currentUser!.preferences, ...preferences},
    );
    
    return await updateCurrentUser(updatedUser);
  }

  // Update user portfolio
  Future<bool> updateUserPortfolio(Map<String, dynamic> portfolio) async {
    if (_currentUser == null) return false;
    
    final updatedUser = _currentUser!.copyWith(
      portfolio: {..._currentUser!.portfolio, ...portfolio},
    );
    
    return await updateCurrentUser(updatedUser);
  }

  // Update user settings
  Future<bool> updateUserSettings(Map<String, dynamic> settings) async {
    if (_currentUser == null) return false;
    
    final updatedUser = _currentUser!.copyWith(
      settings: {..._currentUser!.settings, ...settings},
    );
    
    return await updateCurrentUser(updatedUser);
  }

  // Switch to different user (if multiple users supported)
  Future<bool> switchUser(String userId) async {
    final userData = await getUserData(userId);
    if (userData != null) {
      return await saveUserData(userData);
    }
    return false;
  }

  // Logout current user (clear current user data)
  Future<bool> logout() async {
    if (_prefs == null) await init();
    
    try {
      final success = await _prefs!.remove(_currentUserKey) &&
                     await _prefs!.setBool(_isLoggedInKey, false);
      
      if (success) {
        _currentUser = null;
      }
      
      return success;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Clear all user data (for app reset)
  Future<bool> clearAllUserData() async {
    if (_prefs == null) await init();
    
    try {
      final keys = _prefs!.getKeys();
      final userDataKeys = keys.where((key) => key.startsWith(_userDataPrefix));
      
      for (final key in userDataKeys) {
        await _prefs!.remove(key);
      }
      
      await _prefs!.remove(_currentUserKey);
      await _prefs!.remove(_isLoggedInKey);
      await _prefs!.remove(_lastActiveUserKey);
      
      _currentUser = null;
      return true;
    } catch (e) {
      print('Error clearing all user data: $e');
      return false;
    }
  }

  // Get all stored user IDs (for multi-user support)
  Future<List<String>> getAllUserIds() async {
    if (_prefs == null) await init();
    
    try {
      final keys = _prefs!.getKeys();
      final userDataKeys = keys.where((key) => key.startsWith(_userDataPrefix));
      
      return userDataKeys
          .map((key) => key.substring(_userDataPrefix.length))
          .toList();
    } catch (e) {
      print('Error getting all user IDs: $e');
      return [];
    }
  }

  // Check if specific user data exists
  Future<bool> userDataExists(String userId) async {
    if (_prefs == null) await init();
    
    final userDataKey = '$_userDataPrefix$userId';
    return _prefs!.containsKey(userDataKey);
  }

  // Get user-specific data with fallback
  T? getUserSpecificData<T>(String key, {T? defaultValue}) {
    if (_currentUser == null) return defaultValue;
    
    final userData = _currentUser!.preferences[key] ?? 
                    _currentUser!.portfolio[key] ?? 
                    _currentUser!.settings[key];
    
    if (userData is T) {
      return userData;
    }
    
    return defaultValue;
  }

  // Set user-specific data
  Future<bool> setUserSpecificData(String key, dynamic value, {String category = 'preferences'}) async {
    if (_currentUser == null) return false;
    
    Map<String, dynamic> dataMap;
    switch (category) {
      case 'portfolio':
        dataMap = Map<String, dynamic>.from(_currentUser!.portfolio);
        break;
      case 'settings':
        dataMap = Map<String, dynamic>.from(_currentUser!.settings);
        break;
      default:
        dataMap = Map<String, dynamic>.from(_currentUser!.preferences);
    }
    
    dataMap[key] = value;
    
    UserModel updatedUser;
    switch (category) {
      case 'portfolio':
        updatedUser = _currentUser!.copyWith(portfolio: dataMap);
        break;
      case 'settings':
        updatedUser = _currentUser!.copyWith(settings: dataMap);
        break;
      default:
        updatedUser = _currentUser!.copyWith(preferences: dataMap);
    }
    
    return await updateCurrentUser(updatedUser);
  }

  // WATCHLIST MANAGEMENT
  // Add stock to watchlist
  Future<bool> addToWatchlist(Map<String, dynamic> stock) async {
    if (_currentUser == null) {
      print('Cannot add to watchlist: No current user');
      return false;
    }
    
    print('Adding ${stock['symbol']} to watchlist for user: ${_currentUser!.username}');
    final watchlist = Map<String, dynamic>.from(_currentUser!.portfolio['watchlist'] ?? {});
    watchlist[stock['symbol']] = {
      'symbol': stock['symbol'],
      'name': stock['name'],
      'price': stock['price'],
      'change': stock['change'],
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    };
    
    print('Updated watchlist: $watchlist');
    final success = await setUserSpecificData('watchlist', watchlist, category: 'portfolio');
    print('Watchlist save result: $success');
    return success;
  }

  // Remove stock from watchlist
  Future<bool> removeFromWatchlist(String symbol) async {
    if (_currentUser == null) return false;
    
    final watchlist = Map<String, dynamic>.from(_currentUser!.portfolio['watchlist'] ?? {});
    watchlist.remove(symbol);
    
    return await setUserSpecificData('watchlist', watchlist, category: 'portfolio');
  }

  // Get watchlist
  List<Map<String, dynamic>> getWatchlist() {
    if (_currentUser == null) {
      print('No current user for watchlist');
      return [];
    }
    
    final watchlist = _currentUser!.portfolio['watchlist'] as Map<String, dynamic>? ?? {};
    print('Current watchlist: $watchlist');
    return watchlist.values.cast<Map<String, dynamic>>().toList();
  }

  // Check if stock is in watchlist
  bool isInWatchlist(String symbol) {
    if (_currentUser == null) return false;
    
    final watchlist = _currentUser!.portfolio['watchlist'] as Map<String, dynamic>? ?? {};
    return watchlist.containsKey(symbol);
  }

  // PORTFOLIO MANAGEMENT
  // Buy stock (deduct money and add to holdings)
  Future<bool> buyStock(String symbol, String name, double price, int quantity) async {
    if (_currentUser == null) return false;
    
    final totalCost = price * quantity;
    final currentMoney = (_currentUser!.portfolio['virtualMoney'] as num?)?.toDouble() ?? 10000.0;
    
    // Check if user has enough money
    if (currentMoney < totalCost) {
      return false; // Insufficient funds
    }
    
    final holdings = Map<String, dynamic>.from(_currentUser!.portfolio['holdings'] ?? {});
    final currentHolding = holdings[symbol] as Map<String, dynamic>?;
    
    if (currentHolding != null) {
      // Update existing holding
      final currentQuantity = (currentHolding['quantity'] as num).toInt();
      final currentAvgPrice = (currentHolding['avgPrice'] as num).toDouble();
      final newQuantity = currentQuantity + quantity;
      final newAvgPrice = ((currentQuantity * currentAvgPrice) + totalCost) / newQuantity;
      
      holdings[symbol] = {
        'quantity': newQuantity,
        'avgPrice': newAvgPrice,
        'totalInvested': newQuantity * newAvgPrice,
      };
    } else {
      // Add new holding
      holdings[symbol] = {
        'quantity': quantity,
        'avgPrice': price,
        'totalInvested': totalCost,
      };
    }
    
    // Update portfolio
    final newMoney = currentMoney - totalCost;
    final totalInvested = (_currentUser!.portfolio['totalInvested'] as num?)?.toDouble() ?? 0.0;
    final newTotalInvested = totalInvested + totalCost;
    
    final success = await updateUserPortfolio({
      'virtualMoney': newMoney,
      'holdings': holdings,
      'totalInvested': newTotalInvested,
    });
    
    return success;
  }

  // Sell stock (add money and remove/update holdings)
  Future<bool> sellStock(String symbol, double price, int quantity) async {
    if (_currentUser == null) return false;
    
    final holdings = Map<String, dynamic>.from(_currentUser!.portfolio['holdings'] ?? {});
    final currentHolding = holdings[symbol] as Map<String, dynamic>?;
    
    if (currentHolding == null) {
      return false; // Stock not in portfolio
    }
    
    final currentQuantity = (currentHolding['quantity'] as num).toInt();
    if (currentQuantity < quantity) {
      return false; // Not enough shares to sell
    }
    
    final totalRevenue = price * quantity;
    final currentMoney = (_currentUser!.portfolio['virtualMoney'] as num?)?.toDouble() ?? 10000.0;
    final newMoney = currentMoney + totalRevenue;
    
    if (currentQuantity == quantity) {
      // Remove holding completely
      holdings.remove(symbol);
    } else {
      // Update holding
      final newQuantity = currentQuantity - quantity;
      final avgPrice = (currentHolding['avgPrice'] as num).toDouble();
      holdings[symbol] = {
        'quantity': newQuantity,
        'avgPrice': avgPrice,
        'totalInvested': newQuantity * avgPrice,
      };
    }
    
    // Update portfolio
    final totalInvested = (_currentUser!.portfolio['totalInvested'] as num?)?.toDouble() ?? 0.0;
    final soldValue = (currentHolding['avgPrice'] as num).toDouble() * quantity;
    final newTotalInvested = totalInvested - soldValue;
    
    final success = await updateUserPortfolio({
      'virtualMoney': newMoney,
      'holdings': holdings,
      'totalInvested': newTotalInvested,
    });
    
    return success;
  }

  // Get portfolio holdings
  Map<String, dynamic> getHoldings() {
    if (_currentUser == null) return {};
    return _currentUser!.portfolio['holdings'] as Map<String, dynamic>? ?? {};
  }

  // Get virtual money
  double getVirtualMoney() {
    if (_currentUser == null) return 10000.0;
    return (_currentUser!.portfolio['virtualMoney'] as num?)?.toDouble() ?? 10000.0;
  }

  // Get total invested amount
  double getTotalInvested() {
    if (_currentUser == null) return 0.0;
    return (_currentUser!.portfolio['totalInvested'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total returns (current value - invested amount)
  double getTotalReturns() {
    if (_currentUser == null) return 0.0;
    return (_currentUser!.portfolio['totalReturns'] as num?)?.toDouble() ?? 0.0;
  }

  // Update total returns (call this when stock prices change)
  Future<bool> updateTotalReturns(double newTotalReturns) async {
    return await setUserSpecificData('totalReturns', newTotalReturns, category: 'portfolio');
  }

  // Get portfolio summary
  Map<String, dynamic> getPortfolioSummary() {
    if (_currentUser == null) {
      return {
        'virtualMoney': 10000.0,
        'totalInvested': 0.0,
        'totalReturns': 0.0,
        'totalValue': 10000.0,
        'holdingsCount': 0,
      };
    }
    
    final virtualMoney = getVirtualMoney();
    final totalInvested = getTotalInvested();
    final totalReturns = getTotalReturns();
    final holdings = getHoldings();
    
    return {
      'virtualMoney': virtualMoney,
      'totalInvested': totalInvested,
      'totalReturns': totalReturns,
      'totalValue': virtualMoney + totalInvested + totalReturns,
      'holdingsCount': holdings.length,
    };
  }
}
