import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CustomerSupportPage extends StatefulWidget {
  const CustomerSupportPage({super.key});

  @override
  State<CustomerSupportPage> createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends State<CustomerSupportPage> {
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

  // Contact information
  final String supportEmail = "support@tradingapp.com";
  final String supportPhone = "+91 1800-123-4567";
  final String supportWhatsApp = "+91 98765-43210";
  final String websiteUrl = "www.tradingapp.com";
  final String supportHours = "24x7 Available";

  // Social media
  final String twitterHandle = "@tradingapp";
  final String linkedinUrl = "linkedin.com/company/tradingapp";
  final String instagramHandle = "@tradingapp";
  final String youtubeChannel = "TradingApp Official";

  // Office address
  final String officeAddress = "Trading Tower, 5th Floor\nBandra Kurla Complex\nMumbai, Maharashtra 400051\nIndia";

  // FAQ data
  final List<Map<String, dynamic>> faqList = [
    {
      "question": "How do I add funds to my account?",
      "answer": "You can add funds by going to your Profile > Add Money. We support UPI, Net Banking, and bank transfers. Funds are credited instantly for UPI and within 30 minutes for other methods.",
      "expanded": false,
    },
    {
      "question": "What are the trading charges?",
      "answer": "We offer one of the lowest brokerage rates in India:\n• Equity Delivery: ₹0 (Zero brokerage)\n• Equity Intraday: 0.03% or ₹20 per trade\n• F&O: ₹20 per order\n• Currency & Commodity: 0.03% or ₹20 per trade",
      "expanded": false,
    },
    {
      "question": "How long does KYC verification take?",
      "answer": "KYC verification typically takes 24-48 hours. You'll receive an email and app notification once your KYC is approved. Make sure to submit clear images of your PAN, Aadhaar, and bank proof.",
      "expanded": false,
    },
    {
      "question": "Can I withdraw my funds anytime?",
      "answer": "Yes, you can withdraw funds 24x7. Withdrawals are processed instantly to your linked bank account. Make sure you have sufficient balance after accounting for unsettled trades.",
      "expanded": false,
    },
    {
      "question": "What is the difference between Delivery and Intraday?",
      "answer": "Delivery: Stocks are held in your Demat account and can be sold anytime. No time limit.\n\nIntraday: Buy and sell on the same day. Positions must be squared off before market closes, otherwise auto square-off charges apply.",
      "expanded": false,
    },
    {
      "question": "How do I place a GTT order?",
      "answer": "GTT (Good Till Triggered) orders can be placed from the stock detail page. Click on 'GTT' and set your trigger price. The order remains active for 1 year or until executed.",
      "expanded": false,
    },
    {
      "question": "Is my money safe with you?",
      "answer": "Absolutely! We are registered with SEBI and all member exchanges (NSE, BSE, MCX). Your funds are kept in a separate escrow account with scheduled banks. We follow strict regulatory compliance.",
      "expanded": false,
    },
    {
      "question": "How do I reset my password?",
      "answer": "Click on 'Forgot Password' on the login screen. Enter your registered email/phone number, and you'll receive an OTP to reset your password. You can also change it from Profile > Account Details > Change Password.",
      "expanded": false,
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
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Contact Us"),
                        _buildContactInfo(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Find Us On"),
                        _buildSocialMedia(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Office Address"),
                        _buildOfficeAddress(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Frequently Asked Questions"),
                        _buildFAQSection(),
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
              "Customer Support 24x7",
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.chat_bubble_outline,
              label: "Live Chat",
              onTap: () {
                print("Live Chat tapped");
                // Open live chat
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.email_outlined,
              label: "Email Us",
              onTap: () {
                print("Email Us tapped");
                // Open email client
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.videocam_outlined,
              label: "Video Call",
              onTap: () {
                print("Video Call tapped");
                // Schedule video call
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: accentOrange,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget _buildContactInfo() {
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
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: "Phone Support",
            value: supportPhone,
            onTap: () {
              print("Call $supportPhone");
              // Launch phone dialer
            },
          ),
          _buildDivider(),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: "Email Support",
            value: supportEmail,
            onTap: () {
              print("Email $supportEmail");
              // Launch email client
            },
          ),
          _buildDivider(),
          _buildContactItem(
            icon: Icons.chat_outlined,
            title: "WhatsApp",
            value: supportWhatsApp,
            onTap: () {
              print("WhatsApp $supportWhatsApp");
              // Launch WhatsApp
            },
          ),
          _buildDivider(),
          _buildContactItem(
            icon: Icons.language_outlined,
            title: "Website",
            value: websiteUrl,
            onTap: () {
              print("Open $websiteUrl");
              // Launch browser
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMedia() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSocialCard(
              icon: Icons.tag,
              label: twitterHandle,
              color: const Color(0xFF1DA1F2),
              onTap: () {
                print("Twitter tapped");
                // Open Twitter
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSocialCard(
              icon: Icons.business,
              label: "LinkedIn",
              color: const Color(0xFF0077B5),
              onTap: () {
                print("LinkedIn tapped");
                // Open LinkedIn
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeAddress() {
    return GestureDetector(
      onTap: () {
        print("Open maps");
        // Launch maps app
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
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
                Icons.location_on_outlined,
                color: negativeRed,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Head Office",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    officeAddress,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: faqList.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          color: borderColor,
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        itemBuilder: (context, index) {
          return _buildFAQItem(index);
        },
      ),
    );
  }

  Widget _buildFAQItem(int index) {
    final faq = faqList[index];
    final bool isExpanded = faq["expanded"];

    return GestureDetector(
      onTap: () {
        setState(() {
          faqList[index]["expanded"] = !isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq["question"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: textSecondary,
                  size: 24,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                faq["answer"],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
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