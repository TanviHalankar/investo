import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Theme colors matching home_screen.dart
  final Color darkBg = const Color(0xFF0D0D0D);
  final Color cardDark = const Color(0xFF1A1A1A);
  final Color cardLight = const Color(0xFF242424);
  final Color accentOrange = const Color(0xFFFF9500);
  final Color accentOrangeDim = const Color(0xFFCC7700);
  final Color textPrimary = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFF999999);
  final Color textTertiary = const Color(0xFF666666);
  final Color borderColor = const Color(0xFF2A2A2A);
  final Color positiveGreen = const Color(0xFF00E676);
  final Color negativeRed = const Color(0xFFFF5252);

  // Time period selection
  String selectedPeriod = "1M";
  final List<String> timePeriods = ["1W", "1M", "3M", "6M", "1Y", "All"];

  // Portfolio data
  final double totalInvested = 50000.00;
  final double currentValue = 54750.00;
  final double totalPnL = 4750.00;
  final double totalPnLPercent = 9.5;
  final double dayPnL = 320.50;
  final double dayPnLPercent = 0.59;

  // Trading statistics
  final int totalTrades = 47;
  final int profitableTrades = 32;
  final int lossMakingTrades = 15;
  final double winRate = 68.09;
  final double avgProfit = 285.50;
  final double avgLoss = 156.30;
  final double largestGain = 1250.00;
  final double largestLoss = 680.00;

  // Sector allocation data
  final List<Map<String, dynamic>> sectorData = [
    {"name": "Technology", "percentage": 35.0, "value": 19162.50, "color": Color(0xFF00E676)},
    {"name": "Finance", "percentage": 25.0, "value": 13687.50, "color": Color(0xFFFF9500)},
    {"name": "Healthcare", "percentage": 20.0, "value": 10950.00, "color": Color(0xFF2196F3)},
    {"name": "Consumer", "percentage": 12.0, "value": 6570.00, "color": Color(0xFFE91E63)},
    {"name": "Others", "percentage": 8.0, "value": 4380.00, "color": Color(0xFF9C27B0)},
  ];

  // Top performing stocks
  final List<Map<String, dynamic>> topStocks = [
    {"name": "Reliance Industries", "returns": 15.5, "invested": 12000, "current": 13860},
    {"name": "TCS", "returns": 12.3, "invested": 8500, "current": 9545.50},
    {"name": "HDFC Bank", "returns": 8.7, "invested": 10000, "current": 10870},
    {"name": "Infosys", "returns": 7.2, "invested": 7500, "current": 8040},
  ];

  // Monthly performance data
  final List<Map<String, dynamic>> monthlyData = [
    {"month": "Oct", "pnl": 1250.0},
    {"month": "Nov", "pnl": -320.0},
    {"month": "Dec", "pnl": 890.0},
    {"month": "Jan", "pnl": 1680.0},
    {"month": "Feb", "pnl": 450.0},
    {"month": "Mar", "pnl": 800.0},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = kIsWeb ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                _buildHeader(),
                _buildTimePeriodSelector(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildPortfolioOverview(),
                        const SizedBox(height: 24),
                        _buildTradingStatistics(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Sector Allocation"),
                        _buildSectorAllocation(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Top Performers"),
                        _buildTopPerformers(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Monthly Performance"),
                        _buildMonthlyPerformance(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Trading Insights"),
                        _buildTradingInsights(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: darkBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: textPrimary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Analytics",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("Download report tapped");
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_download_outlined,
                color: textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: timePeriods.map((period) {
            final bool isSelected = selectedPeriod == period;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPeriod = period;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? accentOrange : cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? accentOrange : borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? darkBg : textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildPortfolioOverview() {
    final bool isPositive = totalPnL >= 0;
    final bool isDayPositive = dayPnL >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardDark, cardLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Portfolio Value",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹${currentValue.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total P&L",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? positiveGreen : negativeRed,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${totalPnL.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isPositive ? positiveGreen : negativeRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isPositive ? '+' : ''}${totalPnLPercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? positiveGreen : negativeRed,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: borderColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's P&L",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isDayPositive ? Icons.trending_up : Icons.trending_down,
                          color: isDayPositive ? positiveGreen : negativeRed,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${dayPnL.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDayPositive ? positiveGreen : negativeRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${isDayPositive ? '+' : ''}${dayPnLPercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDayPositive ? positiveGreen : negativeRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Invested",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
                Text(
                  "₹${totalInvested.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: accentOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Trading Statistics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: "Total Trades",
                  value: totalTrades.toString(),
                  icon: Icons.swap_horiz,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: "Win Rate",
                  value: "${winRate.toStringAsFixed(1)}%",
                  icon: Icons.trending_up,
                  valueColor: positiveGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: "Profitable",
                  value: profitableTrades.toString(),
                  icon: Icons.check_circle_outline,
                  valueColor: positiveGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: "Loss Making",
                  value: lossMakingTrades.toString(),
                  icon: Icons.cancel_outlined,
                  valueColor: negativeRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: "Avg Profit",
                  value: "₹${avgProfit.toStringAsFixed(0)}",
                  icon: Icons.arrow_upward,
                  valueColor: positiveGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: "Avg Loss",
                  value: "₹${avgLoss.toStringAsFixed(0)}",
                  icon: Icons.arrow_downward,
                  valueColor: negativeRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: valueColor ?? textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorAllocation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Pie chart representation
          SizedBox(
            height: 200,
            child: Center(
              child: _buildPieChart(),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          ...sectorData.map((sector) => _buildSectorItem(sector)).toList(),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            painter: PieChartPainter(sectorData),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Total",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
            Text(
              "₹${currentValue.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectorItem(Map<String, dynamic> sector) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: sector["color"],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sector["name"],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
            ),
          ),
          Text(
            "${sector["percentage"].toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "₹${sector["value"].toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: topStocks.asMap().entries.map((entry) {
          final index = entry.key;
          final stock = entry.value;
          final bool isLast = index == topStocks.length - 1;

          return Column(
            children: [
              _buildStockPerformanceItem(stock),
              if (!isLast) _buildDivider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockPerformanceItem(Map<String, dynamic> stock) {
    final bool isPositive = stock["returns"] >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock["name"],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Invested: ₹${stock["invested"]}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹${stock["current"]}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? positiveGreen : negativeRed,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${isPositive ? '+' : ''}${stock["returns"].toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? positiveGreen : negativeRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPerformance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: monthlyData.map((data) {
                return _buildBarChart(data);
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: monthlyData.map((data) {
              return Text(
                data["month"],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    final double pnl = data["pnl"];
    final bool isPositive = pnl >= 0;
    final double maxPnl = 2000.0;
    final double height = (pnl.abs() / maxPnl * 140).clamp(20, 140);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPositive)
          Text(
            "₹${pnl.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: positiveGreen,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPositive
                  ? [positiveGreen, positiveGreen.withOpacity(0.6)]
                  : [negativeRed, negativeRed.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        if (!isPositive) ...[
          const SizedBox(height: 4),
          Text(
            "₹${pnl.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: negativeRed,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTradingInsights() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: accentOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Insights & Tips",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.trending_up,
            text: "Your win rate of ${winRate.toStringAsFixed(1)}% is above average. Keep it up!",
            color: positiveGreen,
          ),
          _buildInsightItem(
            icon: Icons.pie_chart_outline,
            text: "Technology sector makes up ${sectorData[0]["percentage"]}% of your portfolio. Consider diversifying.",
            color: accentOrange,
          ),
          _buildInsightItem(
            icon: Icons.savings_outlined,
            text: "Best performing stock: ${topStocks[0]["name"]} with ${topStocks[0]["returns"]}% returns.",
            color: positiveGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color: borderColor,
      ),
    );
  }
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> sectorData;

  PieChartPainter(this.sectorData);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    double startAngle = -90 * 3.14159 / 180; // Start from top

    for (var sector in sectorData) {
      final sweepAngle = (sector["percentage"] / 100) * 2 * 3.14159;
      final paint = Paint()
        ..color = sector["color"]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw white circle in center for donut effect
    final centerPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}