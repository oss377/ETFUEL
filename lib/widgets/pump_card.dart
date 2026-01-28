import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/models/pump_model.dart';

class PumpCard extends StatelessWidget {
  final Pump pump;

  const PumpCard({super.key, required this.pump});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: pump.isUnderMaintenance
            ? const Color(0xFF121a15).withOpacity(0.4)
            : const Color(0xFF121a15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
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
                  pump.isUnderMaintenance ? Icons.build : Icons.local_gas_station,
                  color: pump.isUnderMaintenance
                      ? const Color(0xFF94a3b8)
                      : const Color(0xFF0df259),
                ),
              ),
              Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: pump.isUnderMaintenance
                      ? const Color(0xFF475569)
                      : const Color(0xFF0df259),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Align(
                  alignment: pump.isActive ? Alignment.centerRight : Alignment.centerLeft,
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
            pump.name,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pump.status,
            style: GoogleFonts.inter(
              color: pump.isUnderMaintenance
                  ? const Color(0xFFf59e0b)
                  : const Color(0xFF0df259),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}