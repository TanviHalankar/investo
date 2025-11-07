import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/achievement.dart';
import 'portfolio_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  static final List<Achievement> achievements = [
    // Trading Achievements
    Achievement(
      id: 'first_trade',
      title: 'First Trade',
      description: 'Complete your first stock trade',
      category: 'Trading',
      icon: Icons.shopping_cart,
      pointsReward: 100,
      badgeEmoji: '🎯',
      type: AchievementType.oneTime,
      targetValue: 1,
      hint: 'Buy or sell any stock to unlock this achievement',
    ),
    Achievement(
      id: 'trader_10',
      title: 'Active Trader',
      description: 'Complete 10 trades',
      category: 'Trading',
      icon: Icons.trending_up,
      pointsReward: 500,
      badgeEmoji: '📈',
      type: AchievementType.milestone,
      targetValue: 10,
    ),
    Achievement(
      id: 'trader_50',
      title: 'Expert Trader',
      description: 'Complete 50 trades',
      category: 'Trading',
      icon: Icons.bar_chart,
      pointsReward: 1000,
      badgeEmoji: '🏆',
      type: AchievementType.milestone,
      targetValue: 50,
    ),
    Achievement(
      id: 'profit_1000',
      title: 'Profit Maker',
      description: 'Earn ₹1,000 in profits',
      category: 'Trading',
      icon: Icons.monetization_on,
      pointsReward: 800,
      badgeEmoji: '💰',
      type: AchievementType.milestone,
      targetValue: 1000,
    ),
    Achievement(
      id: 'portfolio_diversified',
      title: 'Diversified Portfolio',
      description: 'Hold stocks from 5 different sectors',
      category: 'Trading',
      icon: Icons.grid_view,
      pointsReward: 600,
      badgeEmoji: '🌍',
      type: AchievementType.oneTime,
      targetValue: 5,
      hint: 'Buy stocks from different industries',
    ),

    // Learning Achievements
    Achievement(
      id: 'first_lesson',
      title: 'Student',
      description: 'Complete your first lesson',
      category: 'Learning',
      icon: Icons.school,
      pointsReward: 50,
      badgeEmoji: '📚',
      type: AchievementType.oneTime,
      targetValue: 1,
    ),
    Achievement(
      id: 'lessons_5',
      title: 'Dedicated Learner',
      description: 'Complete 5 lessons',
      category: 'Learning',
      icon: Icons.menu_book,
      pointsReward: 300,
      badgeEmoji: '🎓',
      type: AchievementType.milestone,
      targetValue: 5,
    ),
    Achievement(
      id: 'lessons_all',
      title: 'Master Learner',
      description: 'Complete all lessons',
      category: 'Learning',
      icon: Icons.emoji_events,
      pointsReward: 1500,
      badgeEmoji: '👑',
      type: AchievementType.oneTime,
      targetValue: 14,
    ),
    Achievement(
      id: 'daily_learner',
      title: 'Daily Learner',
      description: 'Learn for 7 days in a row',
      category: 'Learning',
      icon: Icons.local_fire_department,
      pointsReward: 400,
      badgeEmoji: '🔥',
      type: AchievementType.progressive,
      targetValue: 7,
    ),

    // Portfolio Achievements
    Achievement(
      id: 'portfolio_10000',
      title: 'Portfolio Starter',
      description: 'Build a portfolio worth ₹10,000',
      category: 'Portfolio',
      icon: Icons.account_balance_wallet,
      pointsReward: 200,
      badgeEmoji: '💼',
      type: AchievementType.milestone,
      targetValue: 10000,
    ),
    Achievement(
      id: 'portfolio_50000',
      title: 'Portfolio Builder',
      description: 'Build a portfolio worth ₹50,000',
      category: 'Portfolio',
      icon: Icons.trending_up,
      pointsReward: 800,
      badgeEmoji: '📊',
      type: AchievementType.milestone,
      targetValue: 50000,
    ),
    Achievement(
      id: 'watchlist_10',
      title: 'Stock Watcher',
      description: 'Add 10 stocks to watchlist',
      category: 'Portfolio',
      icon: Icons.bookmark,
      pointsReward: 150,
      badgeEmoji: '👀',
      type: AchievementType.milestone,
      targetValue: 10,
    ),

    // News Achievements
    Achievement(
      id: 'news_reader',
      title: 'Informed Investor',
      description: 'Read 10 news articles',
      category: 'News',
      icon: Icons.article,
      pointsReward: 200,
      badgeEmoji: '📰',
      type: AchievementType.milestone,
      targetValue: 10,
    ),
    Achievement(
      id: 'daily_news',
      title: 'Daily Reader',
      description: 'Read news for 5 consecutive days',
      category: 'News',
      icon: Icons.newspaper,
      pointsReward: 300,
      badgeEmoji: '📖',
      type: AchievementType.progressive,
      targetValue: 5,
    ),

    // Special Achievements
    Achievement(
      id: 'top_10',
      title: 'Top Performer',
      description: 'Reach top 10 in leaderboard',
      category: 'Special',
      icon: Icons.star,
      pointsReward: 1000,
      badgeEmoji: '⭐',
      type: AchievementType.oneTime,
      targetValue: 10,
    ),
    Achievement(
      id: 'chart_master',
      title: 'Chart Master',
      description: 'View 50 stock charts',
      category: 'Special',
      icon: Icons.show_chart,
      pointsReward: 400,
      badgeEmoji: '📈',
      type: AchievementType.milestone,
      targetValue: 50,
    ),
  ];

  Future<Map<String, int>> getUserProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('achievement_progress');
      if (progressJson != null && progressJson.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(progressJson);
        return decoded.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      debugPrint('Error loading achievement progress: $e');
      return {};
    }
  }

  Future<void> _saveProgress(Map<String, int> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(progress);
      await prefs.setString('achievement_progress', progressJson);
    } catch (e) {
      debugPrint('Error saving achievement progress: $e');
    }
  }

  Future<Set<String>> getCompletedAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getStringList('achievements_completed') ?? [];
      return completed.toSet();
    } catch (e) {
      return {};
    }
  }

  Future<void> updateProgress(String achievementId, int progress) async {
    try {
      final progressMap = await getUserProgress();
      progressMap[achievementId] = progress;
      await _saveProgress(progressMap);
      
      // Check if achievement is completed
      final achievement = achievements.firstWhere((a) => a.id == achievementId);
      if (progress >= achievement.targetValue) {
        await completeAchievement(achievementId);
      }
    } catch (e) {
      debugPrint('Error updating achievement progress: $e');
    }
  }

  Future<void> completeAchievement(String achievementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = await getCompletedAchievements();
      
      if (completed.contains(achievementId)) {
        return; // Already completed
      }
      
      completed.add(achievementId);
      await prefs.setStringList('achievements_completed', completed.toList());
      
      // Award points
      final achievement = achievements.firstWhere((a) => a.id == achievementId);
      try {
        final portfolioService = PortfolioService();
        await portfolioService.awardPoints(
          achievement.pointsReward,
          reason: 'achievement:${achievement.id}',
        );
      } catch (e) {
        debugPrint('Error awarding points: $e');
      }
      
      // Sync to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        await userDoc.set({
          'achievements': FieldValue.arrayUnion([achievementId]),
          'lastAchievement': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error completing achievement: $e');
    }
  }

  Future<List<Achievement>> getUserAchievements() async {
    final completed = await getCompletedAchievements();
    return achievements.where((a) => completed.contains(a.id)).toList();
  }

  List<Achievement> getAllAchievements() => achievements;

  List<Achievement> getAchievementsByCategory(String category) {
    return achievements.where((a) => a.category == category).toList();
  }

  List<String> getCategories() {
    return achievements.map((a) => a.category).toSet().toList();
  }

  Achievement? getAchievement(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

