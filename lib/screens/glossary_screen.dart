import 'package:flutter/material.dart';
import '../model/glossary_term.dart';
import '../services/glossary_service.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlossaryService _glossaryService = GlossaryService();
  List<GlossaryTerm> _filteredTerms = [];
  String _selectedCategory = 'All';

  // Color scheme
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _filteredTerms = _glossaryService.getAllTerms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        if (_selectedCategory == 'All') {
          _filteredTerms = _glossaryService.getAllTerms();
        } else {
          _filteredTerms = _glossaryService.getTermsByCategory(_selectedCategory);
        }
      } else {
        _filteredTerms = _glossaryService.searchTerms(_searchController.text);
      }
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        if (_searchController.text.isEmpty) {
          _filteredTerms = _glossaryService.getAllTerms();
        } else {
          _filteredTerms = _glossaryService.searchTerms(_searchController.text);
        }
      } else {
        final categoryTerms = _glossaryService.getTermsByCategory(category);
        if (_searchController.text.isEmpty) {
          _filteredTerms = categoryTerms;
        } else {
          _filteredTerms = categoryTerms.where((term) {
            final query = _searchController.text.toLowerCase();
            return term.term.toLowerCase().contains(query) ||
                term.definition.toLowerCase().contains(query);
          }).toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ..._glossaryService.getCategories()];

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardLight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.menu_book, color: accentOrange, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Stock Glossary',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search terms...',
                    hintStyle: TextStyle(color: textTertiary),
                    prefixIcon: Icon(Icons.search, color: accentOrange),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: textSecondary),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: cardLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => _onCategorySelected(category),
                      selectedColor: accentOrange,
                      checkmarkColor: darkBg,
                      labelStyle: TextStyle(
                        color: isSelected ? darkBg : textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: cardDark,
                      side: BorderSide(
                        color: isSelected ? accentOrange : borderColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Terms List
            Expanded(
              child: _filteredTerms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: textTertiary),
                          const SizedBox(height: 16),
                          Text(
                            'No terms found',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: textTertiary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTerms.length,
                      itemBuilder: (context, index) {
                        return _buildTermCard(_filteredTerms[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermCard(GlossaryTerm term) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(term.icon, color: accentOrange, size: 24),
        ),
        title: Text(
          term.term,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  term.category,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        iconColor: accentOrange,
        collapsedIconColor: textSecondary,
        children: [
          // Definition
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              term.definition,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          // Example
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentOrange.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: accentOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Example:',
                        style: TextStyle(
                          color: accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        term.example,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Related Terms
          if (term.relatedTerms.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Related:',
                  style: TextStyle(
                    color: textTertiary,
                    fontSize: 12,
                  ),
                ),
                ...term.relatedTerms.map((related) {
                  return GestureDetector(
                    onTap: () {
                      final relatedTerm = _glossaryService.getTerm(related);
                      if (relatedTerm != null) {
                        _searchController.text = relatedTerm.term;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        related,
                        style: TextStyle(
                          color: accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

