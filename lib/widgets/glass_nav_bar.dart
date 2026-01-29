import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlassNavBar extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;

  const GlassNavBar({
    super.key,
    required this.onLogout,
    this.onNotificationsPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Always check for current user on every build
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    return Container(
      height: 125,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: const Color(0xFF0a0c10).withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        border: Border(
          left: BorderSide(color: const Color(0xFF256af4).withOpacity(0.2)),
          right: BorderSide(color: const Color(0xFF256af4).withOpacity(0.2)),
          bottom: BorderSide(color: const Color(0xFF256af4).withOpacity(0.2)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left side - User Profile
            _buildUserProfile(currentUser, context),
            
            // Center - Logo
            _buildLogo(),
            
            // Right side - Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(User? currentUser, BuildContext context) {
    // Always extract user info from current user
    final String userName = currentUser != null
        ? (currentUser.displayName ?? 
           currentUser.email?.split('@').first ?? 
           'User')
        : 'Guest';
    
    final String? userPhotoUrl = currentUser?.photoURL;
    
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: currentUser != null ? onProfilePressed : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // User Profile Picture or Initials
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF256af4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: currentUser != null && userPhotoUrl != null && userPhotoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        userPhotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildUserInitials(userName);
                        },
                      ),
                    )
                  : _buildUserInitials(userName),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.25,
              ),
              child: Text(
                userName,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInitials(String userName) {
    return Center(
      child: Text(
        userName.substring(0, 1).toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          color: const Color(0xFF256af4),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Flexible(
      flex: 1,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ev_station,
              color: Color(0xFF256af4),
              size: 28,
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                text: 'ET',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: 'FUEL',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF256af4),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Notification Button with Badge
          Stack(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.notifications,
                  color: Color(0xFF256af4),
                  size: 24,
                ),
                onPressed: onNotificationsPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No notifications'),
                          backgroundColor: Color(0xFF256af4),
                        ),
                      );
                    },
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Logout Button
          Tooltip(
            message: 'Logout',
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF256af4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF256af4)),
              ),
              child: IconButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFF256af4),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1b1f27),
        title: Text(
          'Logout',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? All local data will be cleared.',
          style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9ca6ba)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9ca6ba)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFF256af4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _clearAllLocalData();
      onLogout();
    }
  }

  Future<void> _clearAllLocalData() async {
    try {
      // Clear Firebase Auth session
      await FirebaseAuth.instance.signOut();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear any other local storage if needed
      // Example: Hive, SQFlite, etc.

      print('✅ All local data cleared successfully');
    } catch (e) {
      print('❌ Error clearing local data: $e');
    }
  }
}