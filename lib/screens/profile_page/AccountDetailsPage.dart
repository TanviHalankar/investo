import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
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

  // User account data
  final String userName = "Aryan Niraj Srivastava";
  final String userEmail = "aryan.srivastava@example.com";
  final String userPhone = "+91 98765 43210";
  final String userPAN = "ABCDE1234F";
  final String userDOB = "15 March 1998";
  final String userGender = "Male";

  // Trading account data
  final String tradingAccountId = "TR1234567890";
  final String dematAccountId = "IN30123456789012";
  final String dpId = "IN301234";
  final String clientId = "56789012";
  final String accountStatus = "Active";
  final String kycStatus = "Verified";
  final String accountOpenDate = "20 January 2023";

  // Bank details
  final String bankName = "HDFC Bank";
  final String accountNumber = "1234567890123456";
  final String ifscCode = "HDFC0001234";
  final String accountType = "Savings";

  // Segments enabled
  final List<String> enabledSegments = ["Equity", "F&O", "Currency", "Commodity"];

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Personal Information"),
                          _buildPersonalInfoCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Trading Account"),
                          _buildTradingAccountCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Bank Details"),
                          _buildBankDetailsCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Segments Enabled"),
                          _buildSegmentsCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Account Settings"),
                          _buildAccountSettingsCard(),
                          const SizedBox(height: 24),
                        ],
                      ),
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
              "Account Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print("Edit account details tapped");
              // Navigate to edit page
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: textPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
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

  Widget _buildPersonalInfoCard() {
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
          _buildInfoRow(
            label: "Full Name",
            value: userName,
            icon: Icons.person_outline,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Email",
            value: userEmail,
            icon: Icons.email_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Phone",
            value: userPhone,
            icon: Icons.phone_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "PAN",
            value: userPAN,
            icon: Icons.credit_card_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Date of Birth",
            value: userDOB,
            icon: Icons.cake_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Gender",
            value: userGender,
            icon: Icons.wc_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTradingAccountCard() {
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
          _buildInfoRow(
            label: "Trading Account ID",
            value: tradingAccountId,
            icon: Icons.account_balance_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Demat Account",
            value: dematAccountId,
            icon: Icons.account_balance_wallet_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "DP ID",
            value: dpId,
            icon: Icons.tag_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Client ID",
            value: clientId,
            icon: Icons.badge_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          Row(
            children: [
              Expanded(
                child: _buildStatusChip(
                  label: "Account",
                  value: accountStatus,
                  isActive: accountStatus == "Active",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusChip(
                  label: "KYC",
                  value: kycStatus,
                  isActive: kycStatus == "Verified",
                ),
              ),
            ],
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Account Opening Date",
            value: accountOpenDate,
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard() {
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
          _buildInfoRow(
            label: "Bank Name",
            value: bankName,
            icon: Icons.account_balance_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Account Number",
            value: accountNumber,
            icon: Icons.numbers_outlined,
            showCopy: true,
            maskValue: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "IFSC Code",
            value: ifscCode,
            icon: Icons.code_outlined,
            showCopy: true,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: "Account Type",
            value: accountType,
            icon: Icons.category_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: enabledSegments.map((segment) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentOrange.withOpacity(0.2), accentOrangeDim.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentOrange.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: positiveGreen,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  segment,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccountSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: "Change PIN",
            subtitle: "Update your trading PIN",
            onTap: () {
              print("Change PIN tapped");
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your login password",
            onTap: () {
              print("Change Password tapped");
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.fingerprint_outlined,
            title: "Biometric Login",
            subtitle: "Enable fingerprint/face unlock",
            onTap: () {
              print("Biometric Login tapped");
            },
            trailing: Switch(
              value: true,
              onChanged: (value) {
                print("Biometric toggle: $value");
              },
              activeColor: accentOrange,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.file_download_outlined,
            title: "Download Account Statement",
            subtitle: "Get your account statement",
            onTap: () {
              print("Download Statement tapped");
            },
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.exit_to_app_outlined,
            title: "Logout",
            subtitle: "Sign out from your account",
            onTap: () {
              _showLogoutDialog();
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool showCopy = false,
    bool maskValue = false,
  }) {
    String displayValue = maskValue
        ? "•••• •••• ${value.substring(value.length - 4)}"
        : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: accentOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (showCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Copied to clipboard"),
                    backgroundColor: positiveGreen,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.copy_outlined,
                  color: textPrimary,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required String value,
    required bool isActive,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? positiveGreen : negativeRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
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
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
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
                color: isDestructive ? negativeRed : accentOrange,
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        color: borderColor,
      ),
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
              // Handle logout logic
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
}