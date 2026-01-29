import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/glass_nav_bar.dart';
import '../widgets/particle_background.dart';
import 'car_owner.dart';
import 'notification.dart';
import 'service_page.dart'; // Changed to service_dashboard.dart

class LandingScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onRegisterVehicle;
  final int currentTabIndex;
  final ValueChanged<int>? onTabChanged;
  final ValueChanged<String>? onNavigate;
  final VoidCallback? onLogin;
  final VoidCallback? onRegisterAsDriver;
  final VoidCallback? onRegisterAsStationOwner;
  final String? userName;

  const LandingScreen({
    super.key,
    this.onLogout,
    this.onRegisterVehicle,
    this.currentTabIndex = 0,
    this.onTabChanged,
    this.onNavigate,
    this.onLogin,
    this.onRegisterAsDriver,
    this.onRegisterAsStationOwner, required void Function() onRegisterStation,
    this.userName, required String userRole,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final List<BottomTab> _tabs = [
    BottomTab(icon: Icons.home, label: 'Home'),
    BottomTab(icon: Icons.explore, label: 'Map'),
    BottomTab(icon: Icons.notifications, label: 'Notification'),
    BottomTab(icon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    await Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0c10),
      extendBody: true,
      body: IndexedStack(
        index: widget.currentTabIndex,
        children: [
          _buildHomeTab(),
          CarOwnerHome(
            userName: widget.userName ?? 'Guest',
            onLogout: widget.onLogout ?? () {},
          ),
          const NotificationCenter(),
          const ServiceDashboard(), // Changed to ServiceDashboard
        ],
      ),

      // Bottom Tab Bar
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Particle Background
        const ParticleBackground(),

        // Main Content
        CustomScrollView(
          slivers: [
            // Sticky Glassmorphic Top Nav
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 80,
              collapsedHeight: 80,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: GlassNavBar(
                onLogout: widget.onLogout ?? () {},
                onNotificationsPressed: widget.onNavigate != null
                    ? () => widget.onNavigate!('notifications')
                    : null,
                onProfilePressed: () => widget.onTabChanged?.call(3),
              ),
            ),

            // Hero Section
            SliverToBoxAdapter(child: _buildHeroSection()),

            // Scrolling Ticker
            SliverToBoxAdapter(child: _buildTicker()),

            // Headline Text
            SliverToBoxAdapter(child: _buildHeadline()),

            // CTA Buttons
            SliverToBoxAdapter(child: _buildCTASection()),

            // Stats Grid
            SliverToBoxAdapter(child: _buildStatsGrid()),

            // Footer Logo
            SliverToBoxAdapter(child: _buildFooter()),

            // Bottom Spacing for Floating Nav Bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image with gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF256af4).withValues(alpha: 0.3),
                  const Color(0xFF0a0c10).withValues(alpha: 0.9),
                ],
              ),
            ),
            child: Image.network(
              'https://images.unsplash.com/photo-1536700503339-1e4b06520771?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF256af4).withValues(alpha: 0.2),
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF256af4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Next Gen Network',
                    style: GoogleFonts.spaceGrotesk(
                      color: const Color(0xFF256af4),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text.rich(
                  TextSpan(
                    text: 'The Future of\n',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(
                        text: 'Fueling.',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF256af4),
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Join the most advanced automotive union and access premium fueling benefits globally.',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicker() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF256af4).withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF256af4).withValues(alpha: 0.2),
          ),
          bottom: BorderSide(
            color: const Color(0xFF256af4).withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTickerItem('UNLEADED: \$3.45'),
            _buildTickerItem('•'),
            _buildTickerItem('DIESEL: \$4.12'),
            _buildTickerItem('•'),
            _buildTickerItem('PREMIUM: \$4.89'),
            _buildTickerItem('•'),
            _buildTickerItem('UNION MEMBERS: 52,408'),
            _buildTickerItem('•'),
            _buildTickerItem('ACTIVE STATIONS: 1,290'),
            _buildTickerItem('•'),
            _buildTickerItem('UNLEADED: \$3.45'),
            _buildTickerItem('•'),
            _buildTickerItem('DIESEL: \$4.12'),
            _buildTickerItem('•'),
            _buildTickerItem('PREMIUM: \$4.89'),
            _buildTickerItem('•'),
            _buildTickerItem('UNION MEMBERS: 52,408'),
            _buildTickerItem('•'),
            _buildTickerItem('ACTIVE STATIONS: 1,290'),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          color: const Color(0xFF256af4),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: text == '•' ? 0 : 2,
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            'Power Up Your Drive',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Experience seamless integration between your vehicle and our global network of smart energy hubs.',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Join Button
          InkWell(
            onTap: widget.onRegisterVehicle,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF256af4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF256af4).withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join the Union',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Exclusive Benefits & Rewards',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Find Station Button
          InkWell(
            onTap: () => widget.onNavigate?.call('map'),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF256af4).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find a Station',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Real-time availability',
                        style: GoogleFonts.spaceGrotesk(
                          color: const Color(0xFF256af4),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.near_me, color: const Color(0xFF256af4), size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.electric_car,
              value: '1,240',
              label: 'Nearby EV Hubs',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.savings,
              value: '15.2%',
              label: 'Avg. Member Savings',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF256af4), size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.grey[400],
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.car_repair,
            color: Colors.white.withValues(alpha: 0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'ETFUEL Systems Inc.',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: EdgeInsets.zero,
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0c10).withAlpha(242),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: const Color(0xFF256af4).withAlpha(51)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF256af4).withAlpha(26),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isActive = index == widget.currentTabIndex;

          return GestureDetector(
            onTap: () => widget.onTabChanged?.call(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 20 : 12,
                vertical: 10,
              ),
              decoration: isActive
                  ? BoxDecoration(
                      color: const Color(0xFF256af4).withAlpha(51),
                      borderRadius: BorderRadius.circular(30),
                    )
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    color: isActive
                        ? const Color(0xFF256af4)
                        : Colors.grey[500],
                    size: 24,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Text(
                      tab.label,
                      style: GoogleFonts.spaceGrotesk(
                        color: const Color(0xFF256af4),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomTab {
  final IconData icon;
  final String label;

  BottomTab({required this.icon, required this.label});
}