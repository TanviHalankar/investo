import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'news_model.dart';

class EodhdService {
  static const String _baseUrl = 'https://eodhd.com/api/news';
  static const String _apiToken = '6909b9742072d7.73927045';
  static const String _cacheKey = 'cached_news';
  static const String _cacheTimestampKey = 'cached_news_timestamp';
  static const int _cacheExpirationMinutes = 5; // Cache for 5 minutes
  static const int _maxArticlesPerTicker = 10; // Limit articles per ticker for faster loading

  /// Fetches news articles for a given ticker symbol
  /// [ticker] - The stock ticker symbol (e.g., "AAPL.US", "MSFT.US")
  /// [limit] - Maximum number of articles to return (default: 10)
  /// Returns a list of NewsArticle objects
  /// Throws an exception if the request fails
  Future<List<NewsArticle>> fetchNews(String ticker, {int limit = _maxArticlesPerTicker}) async {
    try {
      final Uri url = Uri.parse('$_baseUrl?s=$ticker&api_token=$_apiToken&fmt=json');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final articles = jsonData.map((json) => NewsArticle.fromJson(json)).toList();
        // Limit results for faster processing
        return articles.take(limit).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  /// Fetches news for multiple ticker symbols in parallel
  /// [tickers] - List of stock ticker symbols
  /// Returns a combined list of NewsArticle objects
  Future<List<NewsArticle>> fetchMultipleNews(List<String> tickers) async {
    try {
      // Fetch all tickers in parallel for much faster loading
      final futures = tickers.map((ticker) => fetchNews(ticker));
      final results = await Future.wait(futures, eagerError: false);
      
      List<NewsArticle> allNews = [];
      for (var newsList in results) {
        if (newsList.isNotEmpty) {
          allNews.addAll(newsList);
        }
      }
      
      // Sort by date (most recent first)
      allNews.sort((a, b) => b.date.compareTo(a.date));
      
      // Remove duplicates based on title
      final seen = <String>{};
      allNews = allNews.where((article) {
        if (seen.contains(article.title)) {
          return false;
        }
        seen.add(article.title);
        return true;
      }).toList();
      
      // Limit total results for faster rendering
      return allNews.take(30).toList();
    } catch (e) {
      throw Exception('Error fetching multiple news: $e');
    }
  }

  /// Gets cached news if available and not expired
  Future<List<NewsArticle>?> getCachedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (cachedJson != null && timestamp != null) {
        final cacheAge = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
        
        if (cacheAge.inMinutes < _cacheExpirationMinutes) {
          final List<dynamic> jsonData = json.decode(cachedJson);
          return jsonData.map((json) => NewsArticle.fromJson(json)).toList();
        }
      }
    } catch (e) {
      // If cache is corrupted, ignore it
    }
    return null;
  }

  /// Saves news to cache
  Future<void> cacheNews(List<NewsArticle> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = articles.map((article) => article.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonData));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // If caching fails, continue without cache
    }
  }

  /// Fetches news with cache support - returns cached data immediately if available
  /// [tickers] - List of stock ticker symbols
  /// [useCache] - Whether to use cache (default: true)
  /// Returns a list with cached articles (if available) and fetches fresh data in background
  Future<List<NewsArticle>> fetchMultipleNewsWithCache(List<String> tickers, {bool useCache = true}) async {
    // Try to get cached news first
    if (useCache) {
      final cachedNews = await getCachedNews();
      if (cachedNews != null && cachedNews.isNotEmpty) {
        // Fetch fresh news in background (don't await)
        fetchMultipleNews(tickers).then((freshNews) {
          cacheNews(freshNews);
        }).catchError((e) {
          // Silently fail background refresh
        });
        return cachedNews;
      }
    }
    
    // No cache available, fetch fresh data
    final freshNews = await fetchMultipleNews(tickers);
    await cacheNews(freshNews);
    return freshNews;
  }
}
