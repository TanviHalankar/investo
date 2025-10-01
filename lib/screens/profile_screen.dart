// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../widgets/custom_button.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
//   late AnimationController _fadeController;
//   late AnimationController _slideController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   final _auth = FirebaseAuth.instance;
//   final _firestore = FirebaseFirestore.instance;
//
//   String _username = '';
//   String _email = '';
//   String _joinDate = 'Loading...';
//   bool _isLoading = true;
//
//   // Platform-aware properties
//   bool get isWeb => kIsWeb;
//   bool get isMobile => !kIsWeb;
//
//   double get maxWidth => isWeb ? 600 : double.infinity;
//   double get horizontalPadding => isWeb ? 40 : 20;
//   double get cardBorderRadius => isWeb ? 20 : 30;
//   double get buttonHeight => isWeb ? 48 : 56;
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
//
//     _fadeController.forward();
//     _slideController.forward();
//
//     _loadUserData();
//   }
//
//   Future<void> _loadUserData() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final userData = await _firestore.collection('users').doc(user.uid).get();
//
//         setState(() {
//           _email = user.email ?? 'No email';
//           _username = _email.split('@')[0];
//
//           if (userData.exists) {
//             final createdAt = userData.data()?['createdAt'] as Timestamp?;
//             if (createdAt != null) {
//               final date = createdAt.toDate();
//               _joinDate = '${date.day}/${date.month}/${date.year}';
//             } else {
//               _joinDate = 'Unknown';
//             }
//           } else {
//             _joinDate = 'Unknown';
//           }
//
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _joinDate = 'Error loading data';
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading profile: $e'),
//           backgroundColor: Colors.red.shade400,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }
//
//   void _signOut() async {
//     try {
//       await _auth.signOut();
//       Navigator.pushReplacementNamed(context, '/login');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error signing out: $e'),
//           backgroundColor: Colors.red.shade400,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isLargeScreen = screenWidth > 800;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF16213e),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF1a1a2e),
//               Color(0xFF16213e),
//               Color(0xFF0f3460),
//               Color(0xFF533483),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             stops: [0.0, 0.3, 0.7, 1.0],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: maxWidth),
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                   : SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: horizontalPadding,
//                     vertical: isWeb ? 20 : 40,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: isWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
//                     children: [
//                       // Animated header section
//                       FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: SlideTransition(
//                           position: _slideAnimation,
//                           child: Column(
//                             children: [
//                               // Profile Avatar
//                               CircleAvatar(
//                                 radius: 60,
//                                 backgroundColor: Colors.white.withOpacity(0.2),
//                                 child: Text(
//                                   _username.isNotEmpty ? _username[0].toUpperCase() : '?',
//                                   style: const TextStyle(
//                                     fontSize: 48,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//
//                               // Username
//                               Text(
//                                 _username,
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//
//                               // Email
//                               Text(
//                                 _email,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.white.withOpacity(0.7),
//                                 ),
//                               ),
//
//                               const SizedBox(height: 10),
//
//                               // Join date
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   'Joined: $_joinDate',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.white.withOpacity(0.8),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 40),
//
//                       // Profile Options
//                       FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: SlideTransition(
//                           position: _slideAnimation,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(cardBorderRadius),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 10,
//                                   spreadRadius: 5,
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(cardBorderRadius),
//                               child: BackdropFilter(
//                                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: Column(
//                                     children: [
//                                       _buildProfileOption(
//                                         icon: Icons.person_outline,
//                                         title: 'Edit Profile',
//                                         onTap: () {
//                                           // TODO: Implement edit profile
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: const Text('Edit Profile - Coming Soon!'),
//                                               backgroundColor: Colors.blue.shade400,
//                                               behavior: SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       const Divider(color: Colors.white24),
//                                       _buildProfileOption(
//                                         icon: Icons.notifications_outlined,
//                                         title: 'Notifications',
//                                         onTap: () {
//                                           // TODO: Implement notifications
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: const Text('Notifications - Coming Soon!'),
//                                               backgroundColor: Colors.blue.shade400,
//                                               behavior: SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       const Divider(color: Colors.white24),
//                                       _buildProfileOption(
//                                         icon: Icons.security_outlined,
//                                         title: 'Security',
//                                         onTap: () {
//                                           // TODO: Implement security
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: const Text('Security - Coming Soon!'),
//                                               backgroundColor: Colors.blue.shade400,
//                                               behavior: SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                       const Divider(color: Colors.white24),
//                                       _buildProfileOption(
//                                         icon: Icons.help_outline,
//                                         title: 'Help & Support',
//                                         onTap: () {
//                                           // TODO: Implement help & support
//                                           ScaffoldMessenger.of(context).showSnackBar(
//                                             SnackBar(
//                                               content: const Text('Help & Support - Coming Soon!'),
//                                               backgroundColor: Colors.blue.shade400,
//                                               behavior: SnackBarBehavior.floating,
//                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 40),
//
//                       // Sign Out Button
//                       FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: SlideTransition(
//                           position: _slideAnimation,
//                           child: CustomButton(
//                             text: 'Sign Out',
//                             color: Colors.red.shade400,
//                             onPressed: _signOut,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileOption({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         child: Row(
//           children: [
//             Icon(icon, color: Colors.white, size: 24),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }