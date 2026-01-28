import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETFUEL - Order Fuel',
      theme: ThemeData.dark(),
      home: const GasOrderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GasOrderScreen extends StatefulWidget {
  const GasOrderScreen({super.key});

  @override
  State<GasOrderScreen> createState() => _GasOrderScreenState();
}

class _GasOrderScreenState extends State<GasOrderScreen> {
  double selectedVolume = 40.0; // liters
  double fuelPrice = 1.84; // price per liter
  String selectedFuelType = '95 Premium';

  final List<Map<String, dynamic>> fuelTypes = [
    {
      'name': '95 Premium',
      'price': 1.84,
      'icon': Icons.local_gas_station,
      'isSelected': true,
    },
    {
      'name': '91 Octane',
      'price': 1.62,
      'icon': Icons.local_gas_station,
      'isSelected': false,
    },
    {
      'name': 'Diesel Plus',
      'price': 1.55,
      'icon': Icons.ev_station,
      'isSelected': false,
    },
  ];

  final List<double> volumePresets = [20.0, 40.0, 60.0];

  double get totalAmount => selectedVolume * fuelPrice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0c12),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top App Bar
              _buildTopAppBar(),

              // Fuel Type Selection
              _buildFuelTypeSelection(),

              // Circular Gauge
              _buildCircularGauge(),

              // Volume Presets
              _buildVolumePresets(),

              // Station Info
              _buildStationInfo(),

              // Checkout Button
              _buildCheckoutButton(),

              // Bottom spacing for scrolling
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Text(
                  'Refuel Your Vehicle',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelTypeSelection() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT FUEL TYPE',
            style: GoogleFonts.inter(
              color: const Color(0xFF9ca6ba),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fuelTypes.length,
              itemBuilder: (context, index) {
                final fuelType = fuelTypes[index];
                final isSelected = fuelType['isSelected'] as bool;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var type in fuelTypes) {
                        type['isSelected'] = false;
                      }
                      fuelType['isSelected'] = true;
                      selectedFuelType = fuelType['name'] as String;
                      fuelPrice = fuelType['price'] as double;
                    });
                  },
                  child: Container(
                    width: 110,
                    margin: EdgeInsets.only(
                      right: index < fuelTypes.length - 1 ? 12 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF256af4).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF256af4)
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF256af4).withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF256af4)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              fuelType['icon'] as IconData,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fuelType['name'] as String,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${fuelType['price'].toString()}/L',
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? const Color(0xFF256af4)
                                  : Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularGauge() {
    double progress = selectedVolume / 80.0; // Max 80L
    double angle = 240 * progress; // 240 degrees max arc
    double startAngle = 150 * math.pi / 180;

    return Container(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Gauge Container
          SizedBox(
            width: 288,
            height: 288,
            child: CustomPaint(
              painter: _CircularGaugePainter(progress: progress),
            ),
          ),

          // Inner Price Display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9ca6ba),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF256af4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF256af4).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${selectedVolume.toStringAsFixed(1)} Liters',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF256af4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          // Slider Thumb (positioned at the end of the arc)
          Positioned(
            left: 144 + 135 * math.sin(startAngle + (240 * progress * math.pi / 180)),
            top: 144 - 135 * math.cos(startAngle + (240 * progress * math.pi / 180)),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF256af4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumePresets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VOLUME PRESETS',
            style: GoogleFonts.inter(
              color: const Color(0xFF9ca6ba),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...volumePresets.map((volume) {
                final isSelected = volume == selectedVolume;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVolume = volume;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF256af4).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF256af4).withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      volume == 60.0 ? '60L' : '${volume.toInt()}L',
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? const Color(0xFF256af4)
                            : Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVolume = 75.0; // Full tank
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Full',
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuARUTCn_n7iyd15tFO3-4ldo5gfzBs0_nxCuBmvRuiD1xZ5rRWib-dvLiGt4_X5vSoeISYEPEjNj-pMBYmP53A7ElyBk3chtPvyZJ0ZnzYrIzDOcN758XRzFtm67Ud6Q-n564rz4Oq6riyGRcdnosKUwdHDoSUaYJ0QVKXV5LeR7Fp7L06WnYBeYQ7KbQZNGvUvdUfy7JZPA-1Bk-erCq4lqbCi5SMTzSH-CG_MR71jesw-XRcJa1fymIirWkiHgkR3oktBIdQHHOyU',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chevron Station #842',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilar, 140 m away',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF9ca6ba),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.location_on, color: Color(0xFF256af4), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Handle order confirmation
            },
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF256af4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF256af4).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Confirm Order',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Text(
                          'Slide to Pay',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SECURED BY APPLE PAY',
            style: GoogleFonts.inter(
              color: const Color(0xFF9ca6ba),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double progress;

  _CircularGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFF1e293b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF256af4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 240 * progress * math.pi / 180;
    final startAngle = 150 * math.pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}