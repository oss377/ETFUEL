import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopNavBar extends StatelessWidget {
  final String? userName;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;
  final VoidCallback? onRegisterAsStationOwner;
  final VoidCallback? onRegisterAsDriver;
  final VoidCallback? onNotificationsPressed;

  const TopNavBar({
    super.key,
    this.userName,
    this.onLogout,
    this.onLogin,
    this.onRegisterAsStationOwner,
    this.onRegisterAsDriver,
    this.onNotificationsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = userName != null && userName!.isNotEmpty;
    
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
          children: [
            // Logo
            Row(
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

            // Right Side Items
            Row(
              children: [
                // User info if logged in
                if (isLoggedIn) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF256af4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF256af4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF256af4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF256af4),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              userName!,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

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
                      onPressed: onNotificationsPressed ?? () {
                        // Default notification action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No notifications'),
                            backgroundColor: Color(0xFF256af4),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
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

                // Login/Logout Button based on auth state
                if (!isLoggedIn) ...[
                  // Login Button
                  TextButton(
                    onPressed: () {
                      if (onLogin != null) {
                        onLogin!();
                      } else {
                        // Show a message since we don't have a login screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login feature coming soon!'),
                            backgroundColor: Color(0xFF256af4),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Register Dropdown Button
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    surfaceTintColor: const Color(0xFF0a0c10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: const Color(0xFF256af4).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    onSelected: (value) {
                      if (value == 'station_owner') {
                        if (onRegisterAsStationOwner != null) {
                          onRegisterAsStationOwner!();
                        } else {
                          // Show message for station owner registration
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Station owner registration coming soon!'),
                              backgroundColor: Color(0xFF256af4),
                            ),
                          );
                        }
                      } else if (value == 'driver') {
                        if (onRegisterAsDriver != null) {
                          onRegisterAsDriver!();
                        } else {
                          // Show message for driver registration
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Driver registration coming soon!'),
                              backgroundColor: Color(0xFF256af4),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'station_owner',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Color(0xFF256af4),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Register as Station Owner',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<String>(
                        value: 'driver',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Color(0xFF256af4),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Register as Driver',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF256af4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF256af4)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Register',
                            style: GoogleFonts.spaceGrotesk(
                              color: const Color(0xFF256af4),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF256af4),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Logout Button when user is logged in
                  Container(
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
                      tooltip: 'Logout',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
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
          'Are you sure you want to logout?',
          style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9ca6ba)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: const Color(0xFF9ca6ba)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onLogout?.call(); // Call logout callback
            },
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
  }
}