import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PumpsScreen extends StatelessWidget {
  const PumpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080d0a),
      child: Center(
        child: Text(
          'Pumps Screen',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}