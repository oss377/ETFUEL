import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080d0a),
      child: Center(
        child: Text(
          'Data Screen',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}