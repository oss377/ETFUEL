import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080d0a),
      child: Center(
        child: Text(
          'Orders Screen',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}