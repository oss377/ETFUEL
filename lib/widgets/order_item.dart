import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final bool isInProgress;

  const OrderItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.isInProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121a15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
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
                      color: const Color(0xFF94a3b8),
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
                  ? const Color(0xFF0df259).withOpacity(0.1)
                  : const Color(0xFF1b271f),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isInProgress
                    ? const Color(0xFF0df259).withOpacity(0.2)
                    : const Color.fromRGBO(255, 255, 255, 0.1),
              ),
            ),
            child: Text(
              status.toUpperCase(),
              style: GoogleFonts.inter(
                color: isInProgress
                    ? const Color(0xFF0df259)
                    : const Color(0xFF94a3b8),
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