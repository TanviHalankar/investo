import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import 'portfolio_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<bool> saveUserData(UserModel user, {bool syncToFirestore = true}) async {
    if (_prefs == null) await init();
    try {
      // Sanitize maps before encoding to JSON (avoid Timestamp/DateTime in local cache)
      final userMap = user.toJson();
      userMap['preferences'] = _sanitizeMap(user.preferences);
      userMap['portfolio'] = _sanitizeMap(user.portfolio);
      userMap['settings'] = _sanitizeMap(user.settings);
      userMap['lessons'] = _sanitizeMap(user.lessons);

      // Save user data with user-specific key
      final userDataKey = '$_userDataPrefix${user.userId}';
      final userDataJson = jsonEncode(userMap);

      // Save current user data
      final currentUserJson = jsonEncode(userMap);

      // Save all data atomically
      final success = await _prefs!.setString(userDataKey, userDataJson) &&
                     await _prefs!.setString(_currentUserKey, currentUserJson) &&
                     await _prefs!.setBool(_isLoggedInKey, true) &&
                     await _prefs!.setString(_lastActiveUserKey, user.userId);

      if (success) {
        _currentUser = user;

        // Firestore sync should not fail the local save
        final uid = FirebaseAuth.instance.currentUser?.uid ?? user.userId;
        if (syncToFirestore && uid.isNotEmpty) {
          try {
            // Check if user document exists before syncing
            final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
            final snapshot = await userDoc.get();
            
            // Only sync if document exists (don't recreate deleted user data)
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .set({
                  'email': user.email,
                  'username': user.username,
                  'displayName': user.displayName,
                  'photoUrl': user.photoUrl,
                  'lastLogin': user.lastLogin.toUtc(),
                  'preferences': user.preferences,
                  'portfolio': user.portfolio,
                  'settings': user.settings,
                  'lessons': user.lessons,
                }, SetOptions(merge: true));
          } catch (e) {
            print('Error syncing user data to Firestore: $e');
          }
        }
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
    final updatedUser = _currentUser!.copyWith(
      portfolio: {..._currentUser!.portfolio, 'watchlist': watchlist},
    );
    final success = await saveUserData(updatedUser);
    print('Watchlist save result: $success');
    if (!success) return false;

    // Also persist in Firestore subcollection
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? _currentUser!.userId;
      await ensureRemoteUserDocument();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchlist')
          .doc(stock['symbol'])
          .set({
            'symbol': stock['symbol'],
            'name': stock['name'],
            'price': stock['price'],
            'change': stock['change'],
            'addedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding watchlist item to Firestore: $e');
    }

    return true;
  }

  // Remove stock from watchlist
  Future<bool> removeFromWatchlist(String symbol) async {
    if (_currentUser == null) return false;
    final watchlist = Map<String, dynamic>.from(_currentUser!.portfolio['watchlist'] ?? {});
    watchlist.remove(symbol);
    final updatedUser = _currentUser!.copyWith(
      portfolio: {..._currentUser!.portfolio, 'watchlist': watchlist},
    );
    final ok = await saveUserData(updatedUser);
    if (!ok) return false;

    // Also remove from Firestore subcollection
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('watchlist')
            .doc(symbol)
            .delete();
      }
    } catch (e) {
      print('Error removing watchlist item from Firestore: $e');
    }
    return true;
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

  // Ensure we have at least a minimal local user cached
  Future<void> ensureLocalUser({
    required String userId,
    required String email,
    required String username,
    String? displayName,
    String? photoUrl,
  }) async {
    if (_currentUser != null) {
      if (_currentUser!.userId == userId) {
        final updated = _currentUser!.copyWith(
          email: email.isNotEmpty ? email : _currentUser!.email,
          username: username.isNotEmpty ? username : _currentUser!.username,
          displayName: displayName ?? _currentUser!.displayName,
          photoUrl: photoUrl ?? _currentUser!.photoUrl,
          lastLogin: DateTime.now(),
        );
        await saveUserData(updated, syncToFirestore: false);
        return;
      }
    }

    final normalizedUsername = username.isNotEmpty
        ? username
        : (email.contains('@') ? email.split('@').first : 'User');

    final fallback = UserModel(
      userId: userId,
      email: email,
      username: normalizedUsername,
      displayName: displayName,
      photoUrl: photoUrl,
      lastLogin: DateTime.now(),
      preferences: {},
      settings: {},
      lessons: {
        'Basics': <String, dynamic>{},
        'News': <String, dynamic>{},
        'Risk Mgmt': <String, dynamic>{},
      },
      portfolio: {
        'virtualMoney': 10000.0,
        'initialMoney': 10000.0,
        'totalMoneyAdded': 0.0,
        'totalInvested': 0.0,
        'totalReturns': 0.0,
        'holdings': <String, dynamic>{},
        'watchlist': <String, dynamic>{},
      },
    );

    await saveUserData(fallback, syncToFirestore: false);
    unawaited(ensureRemoteUserDocument(userOverride: fallback));
  }

  Future<void> ensureRemoteUserDocument({UserModel? userOverride}) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final userModel = userOverride ?? _currentUser;
      final uid = firebaseUser?.uid ?? userModel?.userId;
      if (uid == null || uid.isEmpty) return;

      final email = userModel?.email ?? firebaseUser?.email ?? '';
      final username = userModel?.username ??
          (email.contains('@') ? email.split('@').first : (firebaseUser?.displayName ?? uid));
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final snapshot = await userDoc.get();

      final defaultPortfolio = {
        'virtualMoney': 10000.0,
        'initialMoney': 10000.0,
        'totalMoneyAdded': 0.0,
        'totalInvested': 0.0,
        'totalReturns': 0.0,
        'holdings': <String, dynamic>{},
        'watchlist': <String, dynamic>{},
      };

      final defaultLessons = {
        'Basics': <String, dynamic>{},
        'News': <String, dynamic>{},
        'Risk Mgmt': <String, dynamic>{},
      };

      if (!snapshot.exists) {
        await userDoc.set({
          'uid': uid,
          'email': email,
          'username': username,
          'displayName': userModel?.displayName ?? firebaseUser?.displayName,
          'photoUrl': userModel?.photoUrl ?? firebaseUser?.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'portfolio': (userModel?.portfolio.isNotEmpty ?? false)
              ? userModel!.portfolio
              : defaultPortfolio,
          'lessons': (userModel?.lessons.isNotEmpty ?? false)
              ? userModel!.lessons
              : defaultLessons,
          'achievements': [],
          'points': 0,
        }, SetOptions(merge: true));
      } else {
        await userDoc.set({
          'email': email,
          'username': username,
          'displayName': userModel?.displayName ?? firebaseUser?.displayName,
          'photoUrl': userModel?.photoUrl ?? firebaseUser?.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error ensuring remote user document: $e');
        print(stackTrace);
      }
    }
  }

  Future<void> runPostSignInWarmup({bool waitForCompletion = false}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    Future<void> safeRun(Future<void> future) async {
      try {
        await future;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('Post sign-in warmup error: $e');
          print(stackTrace);
        }
      }
    }

    Future<void> ensureAndLoad() async {
      await ensureRemoteUserDocument();
      await loadFromRemote();
    }

    final tasks = <Future<void>>[
      ensureAndLoad(),
      initializeUserScore(),
      PortfolioService().load(),
    ];

    if (waitForCompletion) {
      await Future.wait(tasks.map(safeRun));
    } else {
      for (final task in tasks) {
        unawaited(safeRun(task));
      }
    }
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
    // Don't update totalInvested here - it should track actual money spent, not current holdings value
    // totalInvested is used for tracking how much was originally invested
    
    final success = await updateUserPortfolio({
      'virtualMoney': newMoney,
      'holdings': holdings,
    });
    
    if (!success) return false;

    // Sync to Firestore: user doc, holdings subcollection, transaction
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    
        // Update minimal portfolio fields in user doc
        await userDoc.set({
          // Keep existing portfolio map updates
          'portfolio': {
            'virtualMoney': newMoney,
            'holdings': holdings,
          },
          // Add top-level cashBalance so PortfolioService can load it later
          'cashBalance': newMoney,
          'updatedAt': DateTime.now().toUtc(),
        }, SetOptions(merge: true));
    
        // Upsert holdings subcollection entry
        final updated = holdings[symbol] as Map<String, dynamic>;
        final q = (updated['quantity'] as num).toInt();
        final avg = (updated['avgPrice'] as num).toDouble();
        await userDoc.collection('holdings').doc(symbol).set({
          'symbol': symbol,
          'name': name,
          'quantity': q,
          'avgPrice': avg,
          'lastPrice': price,
          'marketValue': q * price,
          'invested': q * avg,
          'pnl': (q * price) - (q * avg),
          'pnlPercent': avg == 0 ? 0 : (((price - avg) / avg) * 100),
          'updatedAt': DateTime.now().toUtc(),
        }, SetOptions(merge: true));
    
        // Append transaction
        final txId = DateTime.now().millisecondsSinceEpoch.toString();
        await userDoc.collection('transactions').doc(txId).set({
          'id': txId,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'BUY',
          'symbol': symbol,
          'name': name,
          'quantity': quantity,
          'price': price,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error syncing BUY to Firestore: $e');
    }

    return true;
  }
  Future<void> loadFromRemote() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      final email = (data['email'] as String?) ??
          FirebaseAuth.instance.currentUser?.email ??
          '';
      final username = (data['username'] as String?) ??
          (email.isNotEmpty ? email.split('@').first : '');

      final displayName = data['displayName'] as String?;
      final photoUrl = data['photoUrl'] as String?;

      final lastLoginRaw = data['lastLogin'];
      DateTime lastLogin;
      if (lastLoginRaw is Timestamp) {
        lastLogin = lastLoginRaw.toDate();
      } else if (lastLoginRaw is int) {
        lastLogin = DateTime.fromMillisecondsSinceEpoch(lastLoginRaw);
      } else if (lastLoginRaw is String) {
        lastLogin = DateTime.tryParse(lastLoginRaw) ?? DateTime.now();
      } else {
        lastLogin = DateTime.now();
      }

      final preferences = Map<String, dynamic>.from(data['preferences'] ?? {});
      final portfolio = Map<String, dynamic>.from(data['portfolio'] ?? {});
      final settings = Map<String, dynamic>.from(data['settings'] ?? {});
      final lessons = Map<String, dynamic>.from(data['lessons'] ?? {});

      // Merge and sanitize watchlist subcollection
      try {
        final wlSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('watchlist')
            .get();
        if (wlSnap.docs.isNotEmpty) {
          final wl = <String, dynamic>{};
          for (final d in wlSnap.docs) {
            final s = Map<String, dynamic>.from(d.data());
            final addedAt = s['addedAt'];
            if (addedAt is Timestamp) {
              s['addedAt'] = addedAt.millisecondsSinceEpoch;
            } else if (addedAt is DateTime) {
              s['addedAt'] = addedAt.millisecondsSinceEpoch;
            }
            // price normalization to number if possible
            final price = s['price'];
            if (price is String) {
              s['price'] = double.tryParse(price.replaceAll(',', '')) ?? price;
            }
            // ensure change is a string for UI
            if (s['change'] != null) {
              s['change'] = s['change'].toString();
            }
            wl[d.id] = s;
          }
          portfolio['watchlist'] = wl;
        }
      } catch (_) {
        // ignore watchlist load errors
      }

      final user = UserModel(
        userId: uid,
        email: email,
        username: username.isNotEmpty ? username : 'User',
        displayName: displayName,
        photoUrl: photoUrl,
        lastLogin: lastLogin,
        preferences: preferences,
        portfolio: portfolio,
        settings: settings,
        lessons: lessons,
      );

      await saveUserData(user);
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
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
    
    // Update portfolio - don't modify totalInvested on sell
    // totalInvested tracks original investment, not current holdings
    final success = await updateUserPortfolio({
      'virtualMoney': newMoney,
      'holdings': holdings,
    });
    
    if (!success) return false;

    // Sync to Firestore: user doc, holdings subcollection (delete or update), transaction
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

        // Update minimal portfolio fields in user doc
        await userDoc.set({
          'portfolio': {
            'virtualMoney': newMoney,
            'holdings': holdings,
          },
          'updatedAt': DateTime.now().toUtc(),
        }, SetOptions(merge: true));

        final holdingsCol = userDoc.collection('holdings');
        if (!holdings.containsKey(symbol)) {
          // Remove holding doc if quantity becomes 0
          await holdingsCol.doc(symbol).delete();
        } else {
          final updated = holdings[symbol] as Map<String, dynamic>;
          final q = (updated['quantity'] as num).toInt();
          final avg = (updated['avgPrice'] as num).toDouble();
          await holdingsCol.doc(symbol).set({
            'symbol': symbol,
            'name': currentHolding['name'] ?? symbol,
            'quantity': q,
            'avgPrice': avg,
            'lastPrice': price,
            'marketValue': q * price,
            'invested': q * avg,
            'pnl': (q * price) - (q * avg),
            'pnlPercent': avg == 0 ? 0 : (((price - avg) / avg) * 100),
            'updatedAt': DateTime.now().toUtc(),
          }, SetOptions(merge: true));
        }

        // Append transaction
        final txId = DateTime.now().millisecondsSinceEpoch.toString();
        await userDoc.collection('transactions').doc(txId).set({
          'id': txId,
          'timestamp': DateTime.now().toIso8601String(),
          'action': 'SELL',
          'symbol': symbol,
          'name': currentHolding['name'] ?? symbol,
          'quantity': quantity,
          'price': price,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error syncing SELL to Firestore: $e');
    }

    return true;
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

  // Calculate current portfolio value (cash + current value of holdings)
  // This should be called with current stock prices
  double calculatePortfolioValue(Map<String, double> currentPrices) {
    if (_currentUser == null) return 10000.0;
    
    final virtualMoney = getVirtualMoney();
    final holdings = getHoldings();
    
    double holdingsValue = 0.0;
    holdings.forEach((symbol, holdingData) {
      final quantity = (holdingData['quantity'] as num?)?.toInt() ?? 0;
      final currentPrice = currentPrices[symbol] ?? 0.0;
      holdingsValue += quantity * currentPrice;
    });
    
    return virtualMoney + holdingsValue;
  }

  // Calculate total profit/loss (current portfolio value - initial investment)
  // Initial investment = starting money (10000) - no money can be added
  double calculateProfitLoss(Map<String, double> currentPrices) {
    if (_currentUser == null) return 0.0;
    
    final portfolioValue = calculatePortfolioValue(currentPrices);
    final initialMoney = (_currentUser!.portfolio['initialMoney'] as num?)?.toDouble() ?? 10000.0;
    // No money can be added, so total invested is just initial money
    final totalInvested = initialMoney;
    
    return portfolioValue - totalInvested;
  }

  // Calculate return percentage
  double calculateReturnPercentage(Map<String, double> currentPrices) {
    if (_currentUser == null) return 0.0;
    
    final initialMoney = (_currentUser!.portfolio['initialMoney'] as num?)?.toDouble() ?? 10000.0;
    
    if (initialMoney == 0) return 0.0;
    
    final profitLoss = calculateProfitLoss(currentPrices);
    return (profitLoss / initialMoney) * 100;
  }

  // Add money to virtual account - DISABLED to keep leaderboard fair
  // Users should not be able to add money as it would make the leaderboard unfair
  @Deprecated('Add money feature disabled to maintain fair leaderboard')
  Future<bool> addMoney(double amount) async {
    // Feature disabled - return false
    return false;
  }

  // Update portfolio score for leaderboard
  Future<bool> updatePortfolioScore(Map<String, double> currentPrices) async {
    if (_currentUser == null) return false;
    
    final portfolioValue = calculatePortfolioValue(currentPrices);
    final profitLoss = calculateProfitLoss(currentPrices);
    final returnPercent = calculateReturnPercentage(currentPrices);
    
    final success = await setUserSpecificData('portfolioValue', portfolioValue, category: 'portfolio');
    if (!success) return false;
    
    // Sync to Firestore for leaderboard - ensure username is also set
    // Note: Points are managed by PortfolioService and synced separately
    // We only update portfolioValue, profitLoss, returnPercent here
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': _currentUser!.username, // Ensure username is always set
          'email': _currentUser!.email, // Ensure email is always set
          'portfolioValue': portfolioValue,
          'profitLoss': profitLoss,
          'returnPercent': returnPercent,
          // Don't overwrite points here - PortfolioService manages points (trading + achievements)
          'updatedAt': DateTime.now().toUtc(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error syncing portfolio score to Firestore: $e');
    }
    
    return true;
  }
  
  // Initialize user score in Firestore (call this on login)
  Future<void> initializeUserScore() async {
    if (_currentUser == null) return;
    
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      // Only initialize if user doesn't have points/portfolioValue set
      if (!userDoc.exists || 
          (userDoc.data()?['points'] == null && userDoc.data()?['portfolioValue'] == null)) {
        final initialMoney = (_currentUser!.portfolio['initialMoney'] as num?)?.toDouble() ?? 10000.0;
        
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': _currentUser!.username,
          'email': _currentUser!.email,
          'portfolioValue': initialMoney,
          'points': 0, // Users start with 0 points, not 10,000 (points are earned through trading and achievements)
          'returnPercent': 0.0,
          'profitLoss': 0.0,
          'updatedAt': DateTime.now().toUtc(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error initializing user score: $e');
    }
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

  // LESSON MANAGEMENT
  // Mark lesson as completed with time spent (in seconds)
  Future<bool> markLessonCompleted(String category, String lessonTitle, {int? timeSpentSeconds}) async {
    if (_currentUser == null) {
      print('Cannot mark lesson as completed: No current user');
      return false;
    }
    
    print('Marking lesson as completed: $category - $lessonTitle for user: ${_currentUser!.username}');
    
    final lessons = Map<String, dynamic>.from(_currentUser!.lessons);
    if (!lessons.containsKey(category)) {
      lessons[category] = <String, dynamic>{};
    }
    
    final categoryLessons = Map<String, dynamic>.from(lessons[category] as Map<String, dynamic>? ?? {});
    
    // Get existing lesson data if any
    final existingLesson = categoryLessons[lessonTitle] as Map<String, dynamic>? ?? {};
    final existingTimeSpent = (existingLesson['timeSpentSeconds'] as num?)?.toInt() ?? 0;
    
    // If timeSpentSeconds is provided, add it to existing time; otherwise keep existing
    final totalTimeSpent = timeSpentSeconds != null 
        ? existingTimeSpent + timeSpentSeconds 
        : existingTimeSpent;
    
    categoryLessons[lessonTitle] = {
      'completed': true,
      'completedAt': DateTime.now().millisecondsSinceEpoch,
      'progress': 1.0,
      'timeSpentSeconds': totalTimeSpent,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
    
    lessons[category] = categoryLessons;
    
    print('Updated lessons: $lessons');
    final success = await updateUserLessons(lessons);
    print('Lesson save result: $success');
    return success;
  }

  // Update time spent on a lesson (even if not completed)
  Future<bool> updateLessonTime(String category, String lessonTitle, int timeSpentSeconds) async {
    if (_currentUser == null) {
      print('Cannot update lesson time: No current user');
      return false;
    }
    
    final lessons = Map<String, dynamic>.from(_currentUser!.lessons);
    if (!lessons.containsKey(category)) {
      lessons[category] = <String, dynamic>{};
    }
    
    final categoryLessons = Map<String, dynamic>.from(lessons[category] as Map<String, dynamic>? ?? {});
    
    // Get existing lesson data if any
    final existingLesson = categoryLessons[lessonTitle] as Map<String, dynamic>? ?? {};
    final existingTimeSpent = (existingLesson['timeSpentSeconds'] as num?)?.toInt() ?? 0;
    final totalTimeSpent = existingTimeSpent + timeSpentSeconds;
    
    categoryLessons[lessonTitle] = {
      ...existingLesson,
      'timeSpentSeconds': totalTimeSpent,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      'completed': existingLesson['completed'] ?? false,
      'progress': existingLesson['progress'] ?? 0.0,
    };
    
    lessons[category] = categoryLessons;
    
    return await updateUserLessons(lessons);
  }

  // Get time spent on a specific lesson (in seconds)
  int getLessonTimeSpent(String category, String lessonTitle) {
    if (_currentUser == null) return 0;
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return 0;
    
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons == null || !categoryLessons.containsKey(lessonTitle)) {
      return 0;
    }
    
    final lessonData = categoryLessons[lessonTitle] as Map<String, dynamic>?;
    return (lessonData?['timeSpentSeconds'] as num?)?.toInt() ?? 0;
  }

  // Get total time invested across all lessons (in seconds)
  int getTotalTimeInvested() {
    if (_currentUser == null) return 0;
    
    int totalSeconds = 0;
    final lessons = _currentUser!.lessons;
    
    lessons.forEach((category, categoryLessons) {
      if (categoryLessons is Map<String, dynamic>) {
        categoryLessons.forEach((lessonTitle, lessonData) {
          if (lessonData is Map<String, dynamic>) {
            final timeSpent = (lessonData['timeSpentSeconds'] as num?)?.toInt() ?? 0;
            totalSeconds += timeSpent;
          }
        });
      }
    });
    
    return totalSeconds;
  }

  // Get total time invested for a specific category (in seconds)
  int getCategoryTimeInvested(String category) {
    if (_currentUser == null) return 0;
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return 0;
    
    int totalSeconds = 0;
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons != null) {
      categoryLessons.forEach((lessonTitle, lessonData) {
        if (lessonData is Map<String, dynamic>) {
          final timeSpent = (lessonData['timeSpentSeconds'] as num?)?.toInt() ?? 0;
          totalSeconds += timeSpent;
        }
      });
    }
    
    return totalSeconds;
  }

  // Check if lesson is completed
  bool isLessonCompleted(String category, String lessonTitle) {
    if (_currentUser == null) return false;
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return false;
    
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons == null || !categoryLessons.containsKey(lessonTitle)) {
      return false;
    }
    
    final lessonData = categoryLessons[lessonTitle] as Map<String, dynamic>?;
    return lessonData?['completed'] == true;
  }

  // Get lesson progress
  double getLessonProgress(String category, String lessonTitle) {
    if (_currentUser == null) return 0.0;
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return 0.0;
    
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons == null || !categoryLessons.containsKey(lessonTitle)) {
      return 0.0;
    }
    
    final lessonData = categoryLessons[lessonTitle] as Map<String, dynamic>?;
    return (lessonData?['progress'] as num?)?.toDouble() ?? 0.0;
  }

  // Get completed lessons count for a category
  int getCompletedLessonsCount(String category) {
    if (_currentUser == null) return 0;
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return 0;
    
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons == null) return 0;
    
    int count = 0;
    categoryLessons.forEach((key, value) {
      if (value is Map<String, dynamic> && value['completed'] == true) {
        count++;
      }
    });
    
    return count;
  }

  // Get all completed lessons for a category
  List<String> getCompletedLessons(String category) {
    if (_currentUser == null) return [];
    
    final lessons = _currentUser!.lessons;
    if (!lessons.containsKey(category)) return [];
    
    final categoryLessons = lessons[category] as Map<String, dynamic>?;
    if (categoryLessons == null) return [];
    
    final completed = <String>[];
    categoryLessons.forEach((key, value) {
      if (value is Map<String, dynamic> && value['completed'] == true) {
        completed.add(key);
      }
    });
    
    return completed;
  }

  // Update user lessons
  Future<bool> updateUserLessons(Map<String, dynamic> lessons) async {
    if (_currentUser == null) return false;
    
    final updatedUser = _currentUser!.copyWith(lessons: lessons);
    return await updateCurrentUser(updatedUser);
  }

  // Get all lesson progress
  Map<String, dynamic> getAllLessonProgress() {
    if (_currentUser == null) return {};
    return _currentUser!.lessons;
  }
}

// Sanitization helpers for local storage JSON
Map<String, dynamic> _sanitizeMap(Map<String, dynamic> input) {
  final out = <String, dynamic>{};
  input.forEach((key, value) {
    out[key] = _sanitizeValue(value);
  });
  return out;
}

dynamic _sanitizeValue(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.millisecondsSinceEpoch;
  if (value is DateTime) return value.millisecondsSinceEpoch;
  if (value is num || value is String || value is bool) return value;
  if (value is Map) {
    final m = <String, dynamic>{};
    value.forEach((k, v) {
      m[k.toString()] = _sanitizeValue(v);
    });
    return m;
  }
  if (value is List) {
    return value.map(_sanitizeValue).toList();
  }
  // Fallback to string representation for unknown types
  return value.toString();
}



