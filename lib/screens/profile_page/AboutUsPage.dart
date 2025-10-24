import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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

  // Company info
  final String appVersion = "17.94.1 (24)";
  final String companyName = "TradePro Technologies";
  final String tagline = "Empowering Traders, Building Wealth";
  final String foundedYear = "2020";
  final String headquartersLocation = "Mumbai, India";

  // Stats
  final String activeUsers = "2M+";
  final String dailyTrades = "10M+";
  final String uptime = "99.9%";
  final String customerRating = "4.8";

  // Team members
  final List<Map<String, dynamic>> teamMembers = [
    {
      "name": "Aryan Srivastava",
      "role": "Backend Engineer",
      "icon": Icons.account_circle,
    },
    {
      "name": "Tanvi halankar",
      "role": "Frontend Engineer",
      "icon": Icons.account_circle,
    },
    {
      "name": "Mahi Khhoria",
      "role": "Head of Productions",
      "icon": Icons.account_circle,
    },
    {
      "name": "Shrusti Lastname",
      "role": "ML ead",
      "icon": Icons.account_circle,
    },
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
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 16),
                        _buildStatsSection(),
                        const SizedBox(height: 16),
                        _buildMissionSection(),
                        const SizedBox(height: 16),
                        _buildValuesSection(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Our Team"),
                        _buildTeamSection(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Certifications & Compliance"),
                        _buildCertifications(),
                        const SizedBox(height: 16),
                        _buildSectionTitle("Recognition"),
                        _buildRecognition(),
                        const SizedBox(height: 16),
                        _buildContactSection(),
                        const SizedBox(height: 16),
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
              "About Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentOrange, accentOrangeDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: darkBg.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: textPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            companyName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: darkBg,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tagline,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: darkBg.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: darkBg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Version $appVersion",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkBg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_outline,
              label: "Active Users",
              value: activeUsers,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.swap_horiz,
              label: "Daily Trades",
              value: dailyTrades,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: accentOrange,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  color: accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "Our Mission",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "To democratize trading and investing by providing cutting-edge technology, transparent pricing, and exceptional customer service. We believe everyone deserves access to financial markets with the best tools available.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  "Founded in $foundedYear",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.location_on_outlined,
                  color: textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  headquartersLocation,
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

  Widget _buildValuesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Our Core Values",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildValueItem(
            icon: Icons.shield_outlined,
            title: "Trust & Security",
            description: "Your assets are protected with bank-grade security and regulatory compliance.",
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            icon: Icons.speed_outlined,
            title: "Innovation",
            description: "We constantly evolve with cutting-edge technology to enhance your trading experience.",
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            icon: Icons.visibility_outlined,
            title: "Transparency",
            description: "No hidden charges, clear pricing, and honest communication at every step.",
          ),
          const SizedBox(height: 16),
          _buildValueItem(
            icon: Icons.favorite_outline,
            title: "Customer First",
            description: "24x7 support and resources to help you make informed trading decisions.",
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentOrange,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
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
          Row(
            children: [
              Expanded(
                child: _buildTeamMember(teamMembers[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTeamMember(teamMembers[1]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTeamMember(teamMembers[2]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTeamMember(teamMembers[3]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(Map<String, dynamic> member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentOrange.withOpacity(0.3), accentOrangeDim.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              member["icon"],
              color: textPrimary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            member["name"],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            member["role"],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCertifications() {
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
          _buildCertificationItem(
            icon: Icons.verified_outlined,
            title: "SEBI Registered",
            subtitle: "Reg. No: INZ000123456",
          ),
          const SizedBox(height: 12),
          _buildCertificationItem(
            icon: Icons.account_balance_outlined,
            title: "NSE & BSE Member",
            subtitle: "Trading Member ID: 12345",
          ),
          const SizedBox(height: 12),
          _buildCertificationItem(
            icon: Icons.security_outlined,
            title: "ISO 27001:2013 Certified",
            subtitle: "Information Security Management",
          ),
          const SizedBox(height: 12),
          _buildCertificationItem(
            icon: Icons.policy_outlined,
            title: "CDSL Depository",
            subtitle: "DP ID: IN301234",
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: positiveGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: positiveGreen,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: positiveGreen,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildRecognition() {
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
          _buildRecognitionItem(
            icon: Icons.emoji_events_outlined,
            title: "Best Trading App 2024",
            organization: "Financial Times Awards",
          ),
          const SizedBox(height: 16),
          _buildRecognitionItem(
            icon: Icons.workspace_premium_outlined,
            title: "Top Fintech Startup",
            organization: "India Tech Awards 2023",
          ),
          const SizedBox(height: 16),
          _buildRecognitionItem(
            icon: Icons.star_outline,
            title: "4.8★ Rating",
            organization: "Google Play & App Store",
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionItem({
    required IconData icon,
    required String title,
    required String organization,
  }) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentOrange.withOpacity(0.2), accentOrangeDim.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentOrange,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                organization,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Get in Touch",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Have questions or feedback? We'd love to hear from you!",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              print("Contact Support tapped");
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentOrange, accentOrangeDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent_outlined,
                    color: darkBg,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Contact Support",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkBg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}