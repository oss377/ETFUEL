import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassNavBar extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegisterAsStationOwner;
  final VoidCallback? onRegisterAsDriver;

  const GlassNavBar({
    super.key,
    this.onLogin,
    this.onRegisterAsStationOwner,
    this.onRegisterAsDriver,
  });

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {},
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

                // Login Button
                TextButton(
                  onPressed: onLogin,
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
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'station_owner',
                          onTap: onRegisterAsStationOwner,
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
                          onTap: onRegisterAsDriver,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
