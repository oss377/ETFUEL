import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<BottomTab> _tabs = [
      BottomTab(icon: Icons.dashboard, label: 'Dash'),
      BottomTab(icon: Icons.gas_meter, label: 'Pumps'),
      BottomTab(icon: Icons.add, label: 'Add'), // For floating button
      BottomTab(icon: Icons.receipt_long, label: 'Orders'),
      BottomTab(icon: Icons.analytics, label: 'Data'),
    ];

    return Container(
      margin: EdgeInsets.zero,
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF080d0a).withAlpha(242),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: const Color(0xFF0df259).withAlpha(51)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0df259).withAlpha(26),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // First two tabs on left
          _buildNavItem(_tabs[0], 0),
          _buildNavItem(_tabs[1], 1),
          
          // Floating add button in the middle
          _buildFloatingAddButton(),
          
          // Last two tabs on right
          _buildNavItem(_tabs[3], 3),
          _buildNavItem(_tabs[4], 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BottomTab tab, int index) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
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
                color: const Color(0xFF0df259).withAlpha(51),
                borderRadius: BorderRadius.circular(30),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: isActive
                  ? const Color(0xFF0df259)
                  : const Color(0xFF64748b),
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                tab.label.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFF0df259),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: () => onTabChanged(2),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF0df259),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0df259).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: const Color(0xFF080d0a),
              width: 4,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Color(0xFF080d0a),
            size: 30,
          ),
        ),
      ),
    );
  }
}

class BottomTab {
  final IconData icon;
  final String label;

  BottomTab({required this.icon, required this.label});
}