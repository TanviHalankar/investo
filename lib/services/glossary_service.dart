import 'package:flutter/material.dart';
import '../model/glossary_term.dart';

class GlossaryService {
  static final GlossaryService _instance = GlossaryService._internal();
  factory GlossaryService() => _instance;
  GlossaryService._internal();

  static final List<GlossaryTerm> terms = [
    // Basic Terms
    GlossaryTerm(
      term: 'Stock',
      definition: 'A share of ownership in a company. When you buy a stock, you become a partial owner of that company.',
      category: 'Basic',
      example: 'If you buy 10 shares of Apple stock, you own a small portion of Apple Inc.',
      icon: Icons.account_balance,
      relatedTerms: ['Share', 'Equity', 'Dividend'],
    ),
    GlossaryTerm(
      term: 'Share',
      definition: 'A single unit of stock. Represents one unit of ownership in a company.',
      category: 'Basic',
      example: 'If a company has 1 million shares and you own 1,000, you own 0.1% of the company.',
      icon: Icons.pie_chart,
      relatedTerms: ['Stock', 'Equity'],
    ),
    GlossaryTerm(
      term: 'Portfolio',
      definition: 'A collection of stocks, bonds, and other investments owned by an individual or institution.',
      category: 'Basic',
      example: 'Your portfolio might include stocks from tech companies, banks, and healthcare firms.',
      icon: Icons.work,
      relatedTerms: ['Diversification', 'Asset Allocation'],
    ),
    
    // Market Terms
    GlossaryTerm(
      term: 'Bull Market',
      definition: 'A market condition where stock prices are rising or expected to rise for an extended period.',
      category: 'Market',
      example: 'During a bull market, investors are optimistic and buying stocks, pushing prices higher.',
      icon: Icons.trending_up,
      relatedTerms: ['Bear Market', 'Market Cycle'],
    ),
    GlossaryTerm(
      term: 'Bear Market',
      definition: 'A market condition where stock prices are falling or expected to fall for an extended period.',
      category: 'Market',
      example: 'In a bear market, investors are pessimistic, selling stocks, which causes prices to drop.',
      icon: Icons.trending_down,
      relatedTerms: ['Bull Market', 'Market Cycle'],
    ),
    GlossaryTerm(
      term: 'Market Cap',
      definition: 'The total value of all outstanding shares of a company. Calculated as: Share Price × Total Shares.',
      category: 'Market',
      example: 'If a company has 1 million shares at ₹100 each, its market cap is ₹100 million.',
      icon: Icons.calculate,
      relatedTerms: ['Stock', 'Share'],
    ),
    GlossaryTerm(
      term: 'IPO',
      definition: 'Initial Public Offering - when a private company first sells its shares to the public.',
      category: 'Market',
      example: 'When a startup goes public and sells shares for the first time, it\'s called an IPO.',
      icon: Icons.rocket_launch,
      relatedTerms: ['Stock', 'Market Cap'],
    ),
    
    // Trading Terms
    GlossaryTerm(
      term: 'Buy Order',
      definition: 'An instruction to purchase a stock at a specific price or market price.',
      category: 'Trading',
      example: 'You place a buy order for 10 shares of Reliance at ₹2,850 per share.',
      icon: Icons.shopping_cart,
      relatedTerms: ['Sell Order', 'Market Order', 'Limit Order'],
    ),
    GlossaryTerm(
      term: 'Sell Order',
      definition: 'An instruction to sell a stock at a specific price or market price.',
      category: 'Trading',
      example: 'You place a sell order to sell 5 shares of TCS at ₹3,500 per share.',
      icon: Icons.sell,
      relatedTerms: ['Buy Order', 'Market Order', 'Limit Order'],
    ),
    GlossaryTerm(
      term: 'Market Order',
      definition: 'An order to buy or sell a stock immediately at the current market price.',
      category: 'Trading',
      example: 'A market order executes right away at whatever price the stock is currently trading.',
      icon: Icons.speed,
      relatedTerms: ['Limit Order', 'Stop Loss'],
    ),
    GlossaryTerm(
      term: 'Limit Order',
      definition: 'An order to buy or sell a stock only at a specific price or better.',
      category: 'Trading',
      example: 'You set a limit buy order at ₹2,800 - it only executes if the price drops to ₹2,800 or lower.',
      icon: Icons.timeline,
      relatedTerms: ['Market Order', 'Stop Loss'],
    ),
    GlossaryTerm(
      term: 'Stop Loss',
      definition: 'An order to automatically sell a stock if it falls to a specific price, limiting losses.',
      category: 'Trading',
      example: 'You buy a stock at ₹100 and set a stop loss at ₹90. If it drops to ₹90, it automatically sells.',
      icon: Icons.warning,
      relatedTerms: ['Limit Order', 'Risk Management'],
    ),
    
    // Analysis Terms
    GlossaryTerm(
      term: 'P/E Ratio',
      definition: 'Price-to-Earnings ratio - measures a stock\'s price relative to its earnings per share.',
      category: 'Analysis',
      example: 'A P/E of 25 means investors pay ₹25 for every ₹1 of company earnings.',
      icon: Icons.bar_chart,
      relatedTerms: ['Earnings', 'Valuation'],
    ),
    GlossaryTerm(
      term: 'Dividend',
      definition: 'A portion of a company\'s profits paid to shareholders, usually quarterly.',
      category: 'Analysis',
      example: 'If a company pays ₹5 dividend per share and you own 100 shares, you receive ₹500.',
      icon: Icons.payments,
      relatedTerms: ['Stock', 'Yield'],
    ),
    GlossaryTerm(
      term: 'Volume',
      definition: 'The number of shares traded in a stock during a specific time period.',
      category: 'Analysis',
      example: 'High volume (many trades) often indicates strong interest in a stock.',
      icon: Icons.show_chart,
      relatedTerms: ['Liquidity', 'Market Activity'],
    ),
    GlossaryTerm(
      term: 'Volatility',
      definition: 'How much a stock\'s price fluctuates over time. High volatility means big price swings.',
      category: 'Analysis',
      example: 'Tech stocks are often more volatile than utility stocks, with larger price swings.',
      icon: Icons.waves,
      relatedTerms: ['Risk', 'Beta'],
    ),
    
    // Strategy Terms
    GlossaryTerm(
      term: 'Diversification',
      definition: 'Spreading investments across different stocks, sectors, or assets to reduce risk.',
      category: 'Strategy',
      example: 'Instead of buying only tech stocks, you diversify by also buying healthcare and finance stocks.',
      icon: Icons.grid_view,
      relatedTerms: ['Portfolio', 'Risk Management'],
    ),
    GlossaryTerm(
      term: 'Risk Management',
      definition: 'Strategies to minimize potential losses, such as stop losses and diversification.',
      category: 'Strategy',
      example: 'Using stop losses and diversifying your portfolio are key risk management techniques.',
      icon: Icons.shield,
      relatedTerms: ['Stop Loss', 'Diversification'],
    ),
    GlossaryTerm(
      term: 'Holdings',
      definition: 'The stocks and other investments you currently own in your portfolio.',
      category: 'Strategy',
      example: 'Your holdings might include 50 shares of Reliance, 30 shares of TCS, and cash.',
      icon: Icons.inventory,
      relatedTerms: ['Portfolio', 'Asset Allocation'],
    ),
    GlossaryTerm(
      term: 'Watchlist',
      definition: 'A list of stocks you\'re monitoring but haven\'t bought yet.',
      category: 'Strategy',
      example: 'You add stocks to your watchlist to track their prices before deciding to buy.',
      icon: Icons.bookmark,
      relatedTerms: ['Stock', 'Portfolio'],
    ),
  ];

  List<GlossaryTerm> getAllTerms() => terms;

  List<GlossaryTerm> searchTerms(String query) {
    if (query.isEmpty) return terms;
    final lowerQuery = query.toLowerCase();
    return terms.where((term) {
      return term.term.toLowerCase().contains(lowerQuery) ||
          term.definition.toLowerCase().contains(lowerQuery) ||
          term.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<GlossaryTerm> getTermsByCategory(String category) {
    return terms.where((term) => term.category == category).toList();
  }

  List<String> getCategories() {
    return terms.map((term) => term.category).toSet().toList();
  }

  GlossaryTerm? getTerm(String termName) {
    try {
      return terms.firstWhere(
        (term) => term.term.toLowerCase() == termName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

