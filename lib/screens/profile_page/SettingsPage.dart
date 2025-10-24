import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  // Settings state
  bool biometricEnabled = true;
  bool notificationsEnabled = true;
  bool priceAlertsEnabled = true;
  bool orderUpdatesEnabled = true;
  bool marketNewsEnabled = false;
  bool emailNotifications = true;
  bool smsNotifications = false;
  bool darkModeEnabled = true;
  bool autoLogoutEnabled = false;
  bool twoFactorEnabled = false;
  String selectedLanguage = "English";
  String selectedCurrency = "INR (₹)";
  String autoLogoutTime = "30 minutes";

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
                        _buildSectionTitle("Security"),
                        _buildSecuritySettings(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Notifications"),
                        _buildNotificationSettings(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Appearance"),
                        _buildAppearanceSettings(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Trading Preferences"),
                        _buildTradingPreferences(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Language & Region"),
                        _buildLanguageSettings(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Data & Privacy"),
                        _buildDataPrivacySettings(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("About"),
                        _buildAboutSettings(),
                        const SizedBox(height: 24),
                        _buildDangerZone(),
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
              "Settings",
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: "Biometric Login",
            subtitle: "Use fingerprint or face ID",
            value: biometricEnabled,
            onChanged: (value) {
              setState(() {
                biometricEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.security,
            title: "Two-Factor Authentication",
            subtitle: "Add extra security layer",
            value: twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                twoFactorEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.timer_outlined,
            title: "Auto Logout",
            subtitle: autoLogoutEnabled ? "After $autoLogoutTime" : "Disabled",
            value: autoLogoutEnabled,
            onChanged: (value) {
              setState(() {
                autoLogoutEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.lock_outline,
            title: "Change Trading PIN",
            subtitle: "Update your 4-digit PIN",
            onTap: () {
              print("Change PIN tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.vpn_key_outlined,
            title: "Change Password",
            subtitle: "Update login password",
            onTap: () {
              print("Change Password tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: "Push Notifications",
            subtitle: "Receive app notifications",
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.show_chart,
            title: "Price Alerts",
            subtitle: "Stock price movements",
            value: priceAlertsEnabled,
            onChanged: (value) {
              setState(() {
                priceAlertsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.receipt_long_outlined,
            title: "Order Updates",
            subtitle: "Trade execution alerts",
            value: orderUpdatesEnabled,
            onChanged: (value) {
              setState(() {
                orderUpdatesEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.newspaper_outlined,
            title: "Market News",
            subtitle: "Daily market updates",
            value: marketNewsEnabled,
            onChanged: (value) {
              setState(() {
                marketNewsEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: "Email Notifications",
            subtitle: "Important updates via email",
            value: emailNotifications,
            onChanged: (value) {
              setState(() {
                emailNotifications = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.sms_outlined,
            title: "SMS Notifications",
            subtitle: "Trade alerts via SMS",
            value: smsNotifications,
            onChanged: (value) {
              setState(() {
                smsNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            subtitle: "Use dark theme",
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.palette_outlined,
            title: "Theme Color",
            subtitle: "Orange (Default)",
            onTap: () {
              print("Theme Color tapped");
              _showThemeColorDialog();
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.format_size,
            title: "Font Size",
            subtitle: "Medium",
            onTap: () {
              print("Font Size tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTradingPreferences() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.account_balance_wallet_outlined,
            title: "Default Order Type",
            subtitle: "Market Order",
            onTap: () {
              print("Default Order Type tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.confirmation_number_outlined,
            title: "Default Quantity",
            subtitle: "1 Unit",
            onTap: () {
              print("Default Quantity tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.warning_amber_outlined,
            title: "Order Confirmation",
            subtitle: "Always ask before placing",
            onTap: () {
              print("Order Confirmation tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.update_outlined,
            title: "Market Data Refresh",
            subtitle: "Real-time",
            onTap: () {
              print("Market Data Refresh tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.language_outlined,
            title: "Language",
            subtitle: selectedLanguage,
            onTap: () {
              print("Language tapped");
              _showLanguageDialog();
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.attach_money_outlined,
            title: "Currency",
            subtitle: selectedCurrency,
            onTap: () {
              print("Currency tapped");
              _showCurrencyDialog();
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.access_time_outlined,
            title: "Time Zone",
            subtitle: "IST (GMT+5:30)",
            onTap: () {
              print("Time Zone tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.shield_outlined,
            title: "Privacy Policy",
            subtitle: "Read our privacy policy",
            onTap: () {
              print("Privacy Policy tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            subtitle: "View terms of service",
            onTap: () {
              print("Terms tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.file_download_outlined,
            title: "Download My Data",
            subtitle: "Export your account data",
            onTap: () {
              print("Download Data tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.analytics_outlined,
            title: "Data Usage",
            subtitle: "See how we use your data",
            onTap: () {
              print("Data Usage tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          _buildNavigationTile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle: "17.94.1 (24)",
            onTap: () {
              print("App Version tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.system_update_outlined,
            title: "Check for Updates",
            subtitle: "You're up to date",
            onTap: () {
              print("Check Updates tapped");
              _showUpdateDialog();
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.star_outline,
            title: "Rate Us",
            subtitle: "Share your feedback",
            onTap: () {
              print("Rate Us tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.share_outlined,
            title: "Share App",
            subtitle: "Tell your friends",
            onTap: () {
              print("Share App tapped");
            },
          ),
          _buildDivider(),
          _buildNavigationTile(
            icon: Icons.gavel_outlined,
            title: "Licenses",
            subtitle: "Open source licenses",
            onTap: () {
              print("Licenses tapped");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Danger Zone"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: negativeRed.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              _buildNavigationTile(
                icon: Icons.logout,
                title: "Logout",
                subtitle: "Sign out from this device",
                onTap: () {
                  _showLogoutDialog();
                },
                isDestructive: true,
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.delete_outline,
                title: "Delete Account",
                subtitle: "Permanently delete your account",
                onTap: () {
                  _showDeleteAccountDialog();
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accentOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive
                    ? negativeRed.withOpacity(0.15)
                    : cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? negativeRed : textPrimary,
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
                      color: isDestructive ? negativeRed : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: borderColor,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        title: Text(
          "Logout",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Text(
          "Are you sure you want to logout from your account?",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print("User logged out");
            },
            child: Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: negativeRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: negativeRed.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: negativeRed, size: 28),
            const SizedBox(width: 12),
            Text(
              "Delete Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: negativeRed,
              ),
            ),
          ],
        ),
        content: Text(
          "This action cannot be undone. All your data including trading history, portfolio, and account information will be permanently deleted.",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print("Account deletion initiated");
            },
            child: Text(
              "Delete Forever",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: negativeRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeColorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        title: Text(
          "Choose Theme Color",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption("Orange (Default)", accentOrange, true),
            const SizedBox(height: 12),
            _buildColorOption("Blue", Colors.blue, false),
            const SizedBox(height: 12),
            _buildColorOption("Green", positiveGreen, false),
            const SizedBox(height: 12),
            _buildColorOption("Purple", Colors.purple, false),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String name, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        print("$name selected");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ["English", "हिंदी", "मराठी", "ગુજરાતી", "தமிழ்", "తెలుగు"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        title: Text(
          "Select Language",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            final isSelected = selectedLanguage == lang;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedLanguage = lang;
                });
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? accentOrange.withOpacity(0.15) : cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentOrange : borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: accentOrange,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ["INR (₹)", "USD (\$)", "EUR (€)", "GBP (£)"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        title: Text(
          "Select Currency",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            final isSelected = selectedCurrency == currency;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCurrency = currency;
                });
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? accentOrange.withOpacity(0.15) : cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentOrange : borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: accentOrange,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: positiveGreen, size: 28),
            const SizedBox(width: 12),
            Text(
              "You're up to date!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          "You have the latest version of the app (17.94.1). We'll notify you when a new update is available.",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}