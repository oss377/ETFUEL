import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/stats_card.dart';
import '/widgets/sales_chart.dart';
import '/widgets/pump_card.dart';
import '/widgets/order_item.dart';
import '/models/pump_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
          
            
            // Stats Row
            _buildStatsRow(),
            
            // Sales Chart Section
            _buildSalesChart(),
            
            // Union Partnership Card
            _buildUnionPartnershipCard(),
            
            // Pump Status Header
            _buildPumpManagementHeader(),
            
            // Pump Grid
            _buildPumpGrid(),
            
            // Orders Queue
            _buildOrdersQueue(),
            
            // Bottom Navigation Space
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              title: 'REVENUE',
              value: '\$12,450',
              change: '+14.2%',
              isPositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsCard(
              title: 'VOLUME',
              value: '3.2k gal',
              change: '+5.8%',
              isPositive: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121a15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SALES ANALYTICS',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94a3b8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$48.2k',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF0df259).withOpacity(0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1b271f),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0df259),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '24H',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF080d0a),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Text(
                          '7D',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF94a3b8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SalesChart(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '06:00',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748b),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '12:00',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748b),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '18:00',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748b),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '00:00',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748b),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnionPartnershipCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a2e21),
              Color(0xFF121a15),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0df259).withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0df259).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0df259).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.hub,
                    color: Color(0xFF0df259),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Union Partnership',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ELITE MEMBER TIER',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0df259),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '2,450',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'LOYALTY POINTS',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF94a3b8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPumpManagementHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pump Management',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'EXPAND ALL',
            style: GoogleFonts.inter(
              color: const Color(0xFF0df259),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPumpGrid() {
    final pumps = [
      Pump(
        id: 1,
        name: 'Pump 01',
        status: 'Active & Operational',
        isActive: true,
        isUnderMaintenance: false,
      ),
      Pump(
        id: 2,
        name: 'Pump 02',
        status: 'Active & Operational',
        isActive: true,
        isUnderMaintenance: false,
      ),
      Pump(
        id: 3,
        name: 'Pump 03',
        status: 'Under Maintenance',
        isActive: false,
        isUnderMaintenance: true,
      ),
      Pump(
        id: 4,
        name: 'Pump 04',
        status: 'Active & Operational',
        isActive: true,
        isUnderMaintenance: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: pumps.length,
        itemBuilder: (context, index) {
          return PumpCard(pump: pumps[index]);
        },
      ),
    );
  }

  Widget _buildOrdersQueue() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Queue',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const OrderItem(
            icon: Icons.directions_car,
            title: 'Premium Wash + Wax',
            description: 'Bay #02 • Audi A4 (XYZ-123)',
            status: 'In Progress',
            isInProgress: true,
          ),
          const SizedBox(height: 12),
          const OrderItem(
            icon: Icons.oil_barrel,
            title: 'Oil Change Service',
            description: 'Bay #01 • Ford F-150 (ABC-789)',
            status: 'Queued',
            isInProgress: false,
          ),
        ],
      ),
    );
  }
}