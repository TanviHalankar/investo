import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Holding {
  final String symbol;
  final String name;
  final int quantity;
  final double avgPrice;
  final double lastPrice; // last traded/known price

  const Holding({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    required this.lastPrice,
  });

  double get marketValue => quantity * lastPrice;
  double get invested => quantity * avgPrice;
  double get pnl => marketValue - invested;
  double get pnlPercent => invested == 0 ? 0 : (pnl / invested) * 100;

  Holding copyWith({
    String? symbol,
    String? name,
    int? quantity,
    double? avgPrice,
    double? lastPrice,
  }) {
    return Holding(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgPrice: avgPrice ?? this.avgPrice,
      lastPrice: lastPrice ?? this.lastPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'quantity': quantity,
        'avgPrice': avgPrice,
        'lastPrice': lastPrice,
      };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
        symbol: json['symbol'],
        name: json['name'],
        quantity: (json['quantity'] as num).toInt(),
        avgPrice: (json['avgPrice'] as num).toDouble(),
        lastPrice: (json['lastPrice'] as num).toDouble(),
      );
}

class TransactionItem {
  final String id; // timestamp-based id
  final DateTime timestamp;
  final String action; // BUY or SELL or TOPUP
  final String symbol;
  final String name;
  final int quantity;
  final double price;
  double get total => quantity * price;

  const TransactionItem({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'action': action,
        'symbol': symbol,
        'name': name,
        'quantity': quantity,
        'price': price,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        action: json['action'],
        symbol: json['symbol'],
        name: json['name'],
        quantity: (json['quantity'] as num).toInt(),
        price: (json['price'] as num).toDouble(),
      );
}

class PortfolioState {
  final double cashBalance;
  final Map<String, Holding> holdings;
  final List<TransactionItem> transactions;
  final int points;

  const PortfolioState({
    required this.cashBalance,
    required this.holdings,
    required this.transactions,
    required this.points,
  });

  double get invested => holdings.values.fold(0.0, (p, h) => p + h.invested);
  double get marketValue => holdings.values.fold(0.0, (p, h) => p + h.marketValue);
  double get totalValue => cashBalance + marketValue;
  double get totalPnL => marketValue - invested;

  Map<String, dynamic> toJson() => {
        'cashBalance': cashBalance,
        'holdings': holdings.map((k, v) => MapEntry(k, v.toJson())),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'points': points,
      };

  factory PortfolioState.fromJson(Map<String, dynamic> json) => PortfolioState(
        cashBalance: (json['cashBalance'] as num).toDouble(),
        holdings: (json['holdings'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, Holding.fromJson(Map<String, dynamic>.from(v))),
        ),
        transactions: (json['transactions'] as List<dynamic>)
            .map((e) => TransactionItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        points: (json['points'] as num).toInt(),
      );

  PortfolioState copyWith({
    double? cashBalance,
    Map<String, Holding>? holdings,
    List<TransactionItem>? transactions,
    int? points,
  }) =>
      PortfolioState(
        cashBalance: cashBalance ?? this.cashBalance,
        holdings: holdings ?? this.holdings,
        transactions: transactions ?? this.transactions,
        points: points ?? this.points,
      );
}

class PortfolioService {
  static const _storageKey = 'portfolio_state_v1';
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;

  final _controller = StreamController<PortfolioState>.broadcast();
  PortfolioState _state = const PortfolioState(
    cashBalance: 100000.0, // starting demo money
    holdings: {},
    transactions: [],
    points: 0,
  );

  PortfolioService._internal();

  Stream<PortfolioState> get stream => _controller.stream;
  PortfolioState get state => _state;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _state = PortfolioState.fromJson(decoded);
      } catch (_) {
        // ignore parse errors, keep defaults
      }
    }
    _controller.add(_state);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_state.toJson()));
  }

  // Award simple points logic: 1 point per 100 invested, bonus for streak
  int _calcPointsEarned(double amount, {bool isBuy = true}) {
    final base = (amount / 100).floor();
    return isBuy ? base : (base / 2).floor(); // smaller for sell
  }

  Future<void> buy({
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  }) async {
    if (quantity <= 0) return;
    final cost = quantity * price;
    if (cost > _state.cashBalance) {
      throw Exception('Insufficient funds');
    }

    final existing = _state.holdings[symbol];
    Holding updated;
    if (existing == null || existing.quantity == 0) {
      updated = Holding(
        symbol: symbol,
        name: name,
        quantity: quantity,
        avgPrice: price,
        lastPrice: price,
      );
    } else {
      final newQty = existing.quantity + quantity;
      final newInvested = (existing.quantity * existing.avgPrice) + cost;
      final newAvg = newInvested / newQty;
      updated = existing.copyWith(
        quantity: newQty,
        avgPrice: newAvg,
        lastPrice: price,
      );
    }

    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      action: 'BUY',
      symbol: symbol,
      name: name,
      quantity: quantity,
      price: price,
    );

    final newHoldings = Map<String, Holding>.from(_state.holdings)..[symbol] = updated;
    final newTxs = List<TransactionItem>.from(_state.transactions)..insert(0, tx);
    final newPoints = _state.points + _calcPointsEarned(cost, isBuy: true);

    _state = _state.copyWith(
      cashBalance: _state.cashBalance - cost,
      holdings: newHoldings,
      transactions: newTxs,
      points: newPoints,
    );
    _controller.add(_state);
    await _save();
    await _syncToRemote(addTransaction: tx);
  }

  Future<void> sell({
    required String symbol,
    required String name,
    required int quantity,
    required double price,
  }) async {
    if (quantity <= 0) return;
    final existing = _state.holdings[symbol];
    if (existing == null || existing.quantity < quantity) {
      throw Exception('Not enough shares to sell');
    }

    final proceeds = quantity * price;
    final remainingQty = existing.quantity - quantity;

    Holding? updated;
    if (remainingQty == 0) {
      updated = null; // remove holding
    } else {
      updated = existing.copyWith(
        quantity: remainingQty,
        // keep avgPrice; lastPrice becomes latest trade price
        lastPrice: price,
      );
    }

    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      action: 'SELL',
      symbol: symbol,
      name: name,
      quantity: quantity,
      price: price,
    );

    final newHoldings = Map<String, Holding>.from(_state.holdings);
    if (updated == null) {
      newHoldings.remove(symbol);
    } else {
      newHoldings[symbol] = updated;
    }
    final newTxs = List<TransactionItem>.from(_state.transactions)..insert(0, tx);
    final newPoints = _state.points + _calcPointsEarned(proceeds, isBuy: false);

    _state = _state.copyWith(
      cashBalance: _state.cashBalance + proceeds,
      holdings: newHoldings,
      transactions: newTxs,
      points: newPoints,
    );
    _controller.add(_state);
    await _save();
    await _syncToRemote(addTransaction: tx);
  }

  Future<void> reset() async {
    _state = const PortfolioState(
      cashBalance: 100000.0,
      holdings: {},
      transactions: [],
      points: 0,
    );
    _controller.add(_state);
    await _save();
    await _syncToRemote();
  }

  Future<void> topUp(double amount) async {
    if (amount <= 0) return;
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      action: 'TOPUP',
      symbol: 'WALLET',
      name: 'Demo Money Top-up',
      quantity: 1,
      price: amount,
    );
    _state = _state.copyWith(
      cashBalance: _state.cashBalance + amount,
      transactions: [tx, ..._state.transactions],
    );
    _controller.add(_state);
    await _save();
    await _syncToRemote(addTransaction: tx);
  }

  Future<void> awardPoints(int delta, {String reason = 'bonus'}) async {
    if (delta == 0) return;
    _state = _state.copyWith(points: _state.points + delta);
    _controller.add(_state);
    await _save();
    await _syncToRemote();
  }

  // Firestore sync
  Future<void> _syncToRemote({TransactionItem? addTransaction}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return; // not logged in
      final users = FirebaseFirestore.instance.collection('users');
      final userDoc = users.doc(uid);

      final now = DateTime.now();
      final userData = {
        'cashBalance': _state.cashBalance,
        'invested': _state.invested,
        'marketValue': _state.marketValue,
        'totalValue': _state.totalValue,
        'points': _state.points,
        'email': FirebaseAuth.instance.currentUser?.email,
        'username': FirebaseAuth.instance.currentUser?.email?.split('@').first,
        'updatedAt': now.toUtc(),
      };

      final batch = FirebaseFirestore.instance.batch();
      batch.set(userDoc, userData, SetOptions(merge: true));

      // Upsert holdings as subcollection
      final holdingsCol = userDoc.collection('holdings');
      // Fetch existing to delete removed
      final existing = await holdingsCol.get();
      final keep = _state.holdings.keys.toSet();
      for (final doc in existing.docs) {
        if (!keep.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }
      _state.holdings.forEach((symbol, h) {
        batch.set(holdingsCol.doc(symbol), {
          'symbol': h.symbol,
          'name': h.name,
          'quantity': h.quantity,
          'avgPrice': h.avgPrice,
          'lastPrice': h.lastPrice,
          'marketValue': h.marketValue,
          'invested': h.invested,
          'pnl': h.pnl,
          'pnlPercent': h.pnlPercent,
          'updatedAt': now.toUtc(),
        }, SetOptions(merge: true));
      });

      // Append transaction if provided
      if (addTransaction != null) {
        final txCol = userDoc.collection('transactions');
        batch.set(txCol.doc(addTransaction.id), addTransaction.toJson());
        // also update lastActivityAt
        batch.set(userDoc, {'lastActivityAt': now.toUtc()}, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (_) {
      // Ignore remote sync errors (e.g., insufficient permissions)
    }
  }
}
