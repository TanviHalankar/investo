import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_colors.dart';
import 'eodhd_service.dart';
import 'news_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EodhdService _newsService = EodhdService();
  final TextEditingController _searchController = TextEditingController();
  
  List<NewsArticle> _newsArticles = [];
  bool _isLoading = false;
  String? _errorMessage;
  final List<String> _defaultTickers = ['AAPL.US', 'MSFT.US', 'TSLA.US'];

  @override
  void initState() {
    super.initState();
    // Load news with cache - shows cached data immediately if available
    _loadNewsWithCache();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNewsWithCache() async {
    // Check for cached news first
    final cachedNews = await _newsService.getCachedNews();
    if (cachedNews != null && cachedNews.isNotEmpty) {
      setState(() {
        _newsArticles = cachedNews;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // Fetch fresh news in background
    try {
      final articles = await _newsService.fetchMultipleNewsWithCache(_defaultTickers);
      if (mounted) {
        setState(() {
          _newsArticles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_newsArticles.isEmpty) {
            _errorMessage = e.toString();
          }
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNews({String? ticker}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<NewsArticle> articles;
      if (ticker != null && ticker.isNotEmpty) {
        articles = await _newsService.fetchNews(ticker);
        // Cache the search results
        await _newsService.cacheNews(articles);
      } else {
        articles = await _newsService.fetchMultipleNewsWithCache(_defaultTickers);
      }

      if (mounted) {
        setState(() {
          _newsArticles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      _showSnackBar('No URL available for this article');
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // Light haptic feedback
        HapticFeedback.lightImpact();
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        _showSnackBar('Cannot open article link');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error opening article: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isEmpty) {
      _loadNews();
    } else {
      String ticker = value.trim().toUpperCase();
      if (!ticker.contains('.')) {
        ticker = '$ticker.US';
      }
      _loadNews(ticker: ticker);
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final Duration difference = DateTime.now().difference(date);
      
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getFirstParagraph(String content) {
    // Get first 200 characters or until first newline
    final int endIndex = content.contains('\n\n')
        ? content.indexOf('\n\n')
        : (content.length > 200 ? 200 : content.length);
    
    String summary = content.substring(0, endIndex);
    if (endIndex < content.length) {
      summary += '...';
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        bottom: false,
          child: RefreshIndicator(
            color: AppColors.accentOrange,
            backgroundColor: AppColors.cardDark,
            onRefresh: () async {
              // Force refresh without cache
              if (_searchController.text.trim().isEmpty) {
                final articles = await _newsService.fetchMultipleNews(_defaultTickers);
                await _newsService.cacheNews(articles);
                if (mounted) {
                  setState(() {
                    _newsArticles = articles;
                  });
                }
              } else {
                await _loadNews(ticker: _searchController.text.trim().toUpperCase());
              }
            },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with back button and title
                Container(
                  padding: EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.show_chart, color: AppColors.accentOrange, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'StockPulse',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search ticker (e.g. GOOG.US)',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        prefixIcon: Icon(Icons.search, color: AppColors.accentOrange),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadNews();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.cardLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _onSearchSubmitted,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content Area
                if (_isLoading)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  )
                else if (_errorMessage != null)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildErrorWidget(),
                  )
                else if (_newsArticles.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildEmptyWidget(),
                  )
                else
                  _buildNewsList(),
                  
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.negativeRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No news available',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching for a different ticker',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _newsArticles.map((article) => _buildNewsCard(article)).toList(),
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchUrl(article.link),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Date and Tags
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(article.date),
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (article.symbols.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrangeDim.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.accentOrangeDim,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          article.symbols.first,
                          style: TextStyle(
                            color: AppColors.accentOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Summary/Description
                Text(
                  _getFirstParagraph(article.content),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Footer: Tags
                if (article.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: article.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                // Read more indicator
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      'Tap to read more',
                      style: TextStyle(
                        color: AppColors.accentOrange.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: AppColors.accentOrange.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
