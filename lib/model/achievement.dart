import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final int pointsReward;
  final String badgeEmoji;
  final AchievementType type;
  final int targetValue; // For progress tracking
  final String? hint; // Optional hint for user

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.pointsReward,
    required this.badgeEmoji,
    required this.type,
    required this.targetValue,
    this.hint,
  });
}

enum AchievementType {
  oneTime, // Complete once
  milestone, // Complete at milestones
  daily, // Can complete daily
  progressive, // Progress-based
}

