import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/portfolio_service.dart';

class GuideStep {
  final String id;
  final String title;
  final String message;
  final GlobalKey? anchorKey; // optional: highlight target widget
  final Alignment anchorAlign;
  final Alignment bubbleAlignment; // where to place the bubble

  const GuideStep({
    required this.id,
    required this.title,
    required this.message,
    this.anchorKey,
    this.anchorAlign = Alignment.topCenter,
    this.bubbleAlignment = Alignment.bottomRight,
  });
}

class GuideService {
  static final GuideService _instance = GuideService._internal();
  factory GuideService() => _instance;
  GuideService._internal();

  final _controller = StreamController<GuideStep?>.broadcast();
  GuideStep? _current;
  Set<String> _completed = {};

  Stream<GuideStep?> get stream => _controller.stream;
  GuideStep? get current => _current;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _completed = (prefs.getStringList('guide_completed') ?? []).toSet();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('guide_completed', _completed.toList());
  }

  bool isDone(String id) => _completed.contains(id);

  Future<void> complete(String id, {int award = 0}) async {
    _completed.add(id);
    await _save();
    if (award > 0) {
      await PortfolioService().awardPoints(award, reason: 'guide:$id');
    }
    if (_current?.id == id) {
      _current = null;
      _controller.add(null);
    }
  }

  void show(GuideStep step) {
    if (_completed.contains(step.id)) return;
    print('GuideService.show: Showing tip with id: \'${step.id}\'');
    _current = step;
    _controller.add(step);
  }

  void hide() {
    _current = null;
    _controller.add(null);
  }

  void showNextTip(BuildContext context) {
    // If there's a current tip, complete it
    if (_current != null) {
      complete(_current!.id, award: 5);
    } else {
      // Show a default tip if no current tip is displayed
      show(GuideStep(
        id: 'default_tip',
        title: 'Tip',
        message: 'Explore the app to learn more about investing!',
      ));
    }
  }
}
