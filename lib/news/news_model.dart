class NewsArticle {
  final String date;
  final String title;
  final String content;
  final String? link;
  final List<String> symbols;
  final List<String> tags;
  final Map<String, dynamic>? sentiment;

  NewsArticle({
    required this.date,
    required this.title,
    required this.content,
    this.link,
    required this.symbols,
    required this.tags,
    this.sentiment,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      date: json['date'] ?? '',
      title: json['title'] ?? 'No Title',
      content: json['content'] ?? '',
      link: json['link'],
      symbols: json['symbols'] != null 
          ? List<String>.from(json['symbols']) 
          : [],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : [],
      sentiment: json['sentiment'] != null && json['sentiment'] is Map
          ? Map<String, dynamic>.from(json['sentiment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'title': title,
      'content': content,
      'link': link,
      'symbols': symbols,
      'tags': tags,
      'sentiment': sentiment,
    };
  }
  
  // Helper method to get sentiment polarity if available
  double? getSentimentPolarity() {
    if (sentiment != null && sentiment!.containsKey('polarity')) {
      return (sentiment!['polarity'] as num?)?.toDouble();
    }
    return null;
  }
}
