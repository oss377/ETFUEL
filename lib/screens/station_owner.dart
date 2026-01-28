import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StationOwnerDashboard extends StatelessWidget {
  const StationOwnerDashboard({super.key, required String userName, required void Function() onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080d0a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopNavBar(),
              
              // Stats Row
              _buildStatsRow(),
              
              // Sales Chart Section
              _buildSalesChart(),
              
              // Union Partnership Card
              _buildUnionPartnershipCard(),
              
              // Pump Management Header
              _buildPumpManagementHeader(),
              
              // Pump Grid
              _buildPumpGrid(),
              
              // Service Queue
              _buildServiceQueue(),
              
              // Bottom Navigation Space
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080d0a).withValues(alpha: 0.8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0df259).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0df259).withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDM03GGWXJIu7AU4u5dy3BkG_kgUjd0oWV5aw8A_fv4luQKlqwgSSjL7zG11P34JlroBMZqjjkvlj_nQZ7iWbbnCpWqysBT1VQchWhPQSimmvuEN6aWRN7elCuh6_nesqFZGEtX_HdBHxhjiCZ_iuopvthOqAnvU24pew9mrPPgZ4KhRfekhl7-VlRM8nSNJ8wNitO8fck12JasRmXf0JGf20qnvEVLFfYQpySekdGe0FGaHrCw8DnHDlWFwO_X5wCs9c4GawdwZNOQ',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, rrrr',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0df259),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0df259).withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'System Online',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0df259),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1b271f),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1b271f),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121a15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RE',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$12,450',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF0df259),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+14.2%',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0df259),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121a15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VOLUME',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3.2k gal',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF0df259),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+5.8%',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0df259),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121a15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$48.2k',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF0df259).withValues(alpha: 0.6),
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                            color: Colors.grey[400],
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
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _ChartPainter(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '06:00',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '12:00',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '18:00',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '00:00',
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
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
      padding: const EdgeInsets.all(16.0),
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
            color: const Color(0xFF0df259).withValues(alpha: 0.2),
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
                    color: const Color(0xFF0df259).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0df259).withValues(alpha: 0.3),
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
                    const SizedBox(height: 2),
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
                    color: Colors.grey[400],
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
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: [
          _buildPumpCard(
            pumpNumber: '01',
            status: 'Active & Operational',
            isActive: true,
          ),
          _buildPumpCard(
            pumpNumber: '02',
            status: 'Active & Operational',
            isActive: true,
          ),
          _buildPumpCard(
            pumpNumber: '03',
            status: 'Under Maintenance',
            isActive: false,
          ),
          _buildPumpCard(
            pumpNumber: '04',
            status: 'Active & Operational',
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPumpCard({
    required String pumpNumber,
    required String status,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF121a15) : const Color(0xFF121a15).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1b271f),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isActive ? Icons.local_gas_station : Icons.build,
                  color: isActive ? const Color(0xFF0df259) : Colors.grey[500],
                ),
              ),
              Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF0df259) : Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Align(
                  alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF080d0a),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Pump $pumpNumber',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: GoogleFonts.inter(
              color: isActive 
                  ? const Color(0xFF0df259) 
                  : const Color(0xFFFFB74D),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceQueue() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
          _buildServiceItem(
            icon: Icons.directions_car,
            title: 'Premium Wash + Wax',
            description: 'Bay #02 • Audi A4 (XYZ-123)',
            status: 'In Progress',
            isInProgress: true,
          ),
          const SizedBox(height: 12),
          _buildServiceItem(
            icon: Icons.oil_barrel,
            title: 'Oil ',
            description: 'Bay #01 • Ford F-150 (ABC-789)',
            status: 'Queued',
            isInProgress: false,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String description,
    required String status,
    required bool isInProgress,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121a15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1b271f),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isInProgress
                  ? const Color(0xFF0df259).withValues(alpha: 0.1)
                  : const Color(0xFF1b271f),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isInProgress
                    ? const Color(0xFF0df259).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.inter(
                color: isInProgress
                    ? const Color(0xFF0df259)
                    : Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0df259)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0df259).withValues(alpha: 0.3),
          const Color(0xFF0df259).withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.05, size.height * 0.8,
        size.width * 0.1, size.height * 0.27,
        size.width * 0.15, size.height * 0.27,
      )
      ..cubicTo(
        size.width * 0.2, size.height * 0.27,
        size.width * 0.25, size.height * 0.6,
        size.width * 0.3, size.height * 0.6,
      )
      ..cubicTo(
        size.width * 0.35, size.height * 0.6,
        size.width * 0.4, size.height * 0.13,
        size.width * 0.45, size.height * 0.13,
      )
      ..cubicTo(
        size.width * 0.5, size.height * 0.13,
        size.width * 0.55, size.height * 0.67,
        size.width * 0.6, size.height * 0.67,
      )
      ..cubicTo(
        size.width * 0.65, size.height * 0.67,
        size.width * 0.7, size.height * 0.07,
        size.width * 0.75, size.height * 0.07,
      )
      ..cubicTo(
        size.width * 0.8, size.height * 0.07,
        size.width * 0.85, size.height * 0.87,
        size.width * 0.9, size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.95, size.height * 0.87,
        size.width, size.height * 0.4,
        size.width, size.height * 0.4,
      );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}