import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


import 'AboutUsPage.dart';
import 'AccountDetailsPage.dart';
import 'AnalyticsPage.dart';
import 'CustomerSupportPage.dart';
import 'OrdersPage.dart';
import 'SettingsPage.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
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

  // User data
  final String userName = "Aryanr Srivastava";
  final String userBalance = "₹10000.00";
  final String balanceSubtitle = "Stocks, F&O balance";
  final String versionText = "Version 1.1.1";

  // Profile image placeholder
  final String profileImageUrl = "https://avatars.githubusercontent.com/u/98484953?s=400&u=518671a09f9b75967707be40e9dc4b246f4dc85e&v=4"; // Add your image URL here

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildMenuList(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate back
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
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        // Profile Image
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC837), Color(0xFFFF9500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ClipOval(
            child: profileImageUrl.isNotEmpty
                ? Image.network(
              profileImageUrl,
              fit: BoxFit.cover,
            )
                : Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "A",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // User Name
        Text(
          userName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Balance Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userBalance,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balanceSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to add money
                  print("Add money tapped");
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentOrange, accentOrangeDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Add money",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.receipt_long_outlined,
          title: "Orders",
          onTap: () {

            Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
          },
        ),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: "Account details",
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsPage()));
          },
        ),
        _buildMenuItem(
          icon: Icons.analytics_outlined,
          title: "Analytics",
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsPage()));
          },
        ),
        _buildMenuItem(
          icon: Icons.headset_mic_outlined,
          title: "Customer support 24x7",
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerSupportPage()));
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
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
                color: textPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
            },
            child: Text(
              "About us",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            versionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textTertiary,
            ),
          ),

        ],
      ),
    );
  }
}