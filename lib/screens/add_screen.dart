import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF080d0a),
      child: Center(
        child: Text(
          'Add Screen',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}