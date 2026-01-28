import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETFUEL - Service Dashboard',
      theme: ThemeData.dark(),
      home: const ServiceDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ServiceDashboard extends StatefulWidget {
  const ServiceDashboard({super.key});

  @override
  State<ServiceDashboard> createState() => _ServiceDashboardState();
}

class _ServiceDashboardState extends State<ServiceDashboard> {
  double progressValue = 0.75; // 75% progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0c10),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [Color(0xFF0a0c10), Color(0xFF0a0c10)],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Loyalty Circular Section
                _buildLoyaltySection(),

                // Active Services Header
                _buildServicesHeader(),

                // Service Grid
                _buildServiceGrid(),

                // Nearby Stations Panel
                _buildNearbyStationsPanel(),

                // Bottom Navigation Space
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      // The bottom navigation bar has been removed as per your request.
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF256af4).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuD8XQhgV3XXLqm5IhPr6BIxra0UP5Qjn8XNeHOvFkwh8w4KoH7Z056cadgOPEuFv2gd_DlnyE4Qfg1xw7ewlN5Qt-nZVpJXQTCC0o63SbMhalDE3SL8KH-3-UpARd4JSM5pelxbQaMQWXn0d8fg8zsxnzNqugak_86efsg5ia_xD0bdBusHQFczIazER3c3KflXlwwPAhvbXOOVDuJC5WbCO4B99LjOjcPsBKsamlYQH6-6xrNDUAtfH4kn7luuCMCs7m6Y1MD6WYVa',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF0a0c10),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREMIUM MEMBER',
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Alex Rivera',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 224,
            height: 224,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring
                Container(
                  width: 224,
                  height: 224,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(112),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 6,
                    ),
                  ),
                ),

                // Progress Ring
                Transform.rotate(
                  angle: 45 * 3.1415926535 / 180,
                  child: Container(
                    width: 224,
                    height: 224,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(112),
                      border: Border.all(color: Colors.transparent, width: 6),
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFF256af4),
                          Color(0xFF256af4),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.75, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                // Inner Glass Card
                Container(
                  width: 176,
                  height: 176,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(88),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.37),
                        blurRadius: 32,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TOTAL POINTS',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF256af4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '5,240',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gold Tier',
                        style: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick Info Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.37),
                      blurRadius: 32,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_gas_station,
                      color: Color(0xFF256af4),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '12% Fuel Disc.',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.37),
                      blurRadius: 32,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF256af4), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'VIP Lounge',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Active Services',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'View All',
            style: GoogleFonts.inter(
              color: const Color(0xFF256af4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
        children: [
          _buildServiceCard(
            title: 'Order Fuel',
            subtitle: 'Direct Delivery',
            icon: Icons.local_gas_station,
            color: const Color(0xFF256af4),
            isHighlighted: false,
          ),
          _buildServiceCard(
            title: 'Car Wash',
            subtitle: 'Book Premium',
            icon: Icons.water_drop,
            color: Colors.cyan,
            isHighlighted: false,
          ),
          _buildServiceCard(
            title: 'Union Benefits',
            subtitle: 'Exclusive Perks',
            icon: Icons.loyalty,
            color: Colors.amber,
            isHighlighted: false,
          ),
          _buildServiceCard(
            title: 'SOS Help',
            subtitle: 'Roadside Assist',
            icon: Icons.emergency,
            color: const Color(0xFF256af4),
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isHighlighted,
  }) {
    return GestureDetector(
      onTap: () {
        if (title == 'Order Fuel') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GasOrderScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF256af4).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.37),
              blurRadius: 32,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -16,
              top: -16,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? color
                          : color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isHighlighted
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isHighlighted ? Colors.white : color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
                      fontSize: 12,
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

  Widget _buildNearbyStationsPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white.withValues(alpha: 0.05), Colors.transparent],
          ),
        ),
        child: Stack(
          children: [
            // Map Background
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.33,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCUjmXSU10T7s9eKcbP6QT2K_-j2GBLTGN_ThK-ioPlMZgPdah8gU6H9aIJtj8ssqbHbAcSmac3R_Lo7QNMe2dVO68pNrKrF24cbdZzz7k2CgjRhm-uCW_Y9r_7jAXlOT7-ilRuhjGqsTV3OpCEpZMnuSpXY2gEvkUJD-dWhqPIpTNwmiLWdn78pr13Dc71DjNBqIx1VTNp0zoKjE9TFlhibaeDzBJX7b2H8lj4nNnyyeFQ4Hc594vC0BlhS3Jx0B0RKKRYokiJGD0t',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby Stations',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: Text(
                          '3 stations found within 5 miles of your location.',
                          style: GoogleFonts.inter(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF256af4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF256af4).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Find Station',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
