import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'pumps_screen.dart';
import 'orders_screen.dart';
import 'data_screen.dart';
import 'add_screen.dart';
import 'package:gas_station/widgets/glass_tab_bar_station.dart';
import 'package:gas_station/widgets/top_nav_bar.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080d0a),
      body: Stack(
        children: [
          // Main content - positioned to start below where the TopNavBar will be
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: _screens[_currentIndex],
          ),
          
          // Glassmorphic TopNavBar fixed at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                // Gradient overlay for glass effect
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF080d0a).withOpacity(0.9),
                    const Color(0xFF080d0a).withOpacity(0.7),
                    const Color(0xFF080d0a).withOpacity(0.0),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: TopNavBar(
           
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTabChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Your existing screens list
  final List<Widget> _screens = [
    DashboardScreen(
       ),
    PumpsScreen(),
    AddScreen(),
    OrdersScreen(),
    DataScreen(),
  ];
}