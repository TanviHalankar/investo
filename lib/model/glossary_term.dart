import 'package:flutter/material.dart';

class GlossaryTerm {
  final String term;
  final String definition;
  final String category;
  final String example;
  final IconData icon;
  final List<String> relatedTerms;

  GlossaryTerm({
    required this.term,
    required this.definition,
    required this.category,
    required this.example,
    required this.icon,
    this.relatedTerms = const [],
  });
}

