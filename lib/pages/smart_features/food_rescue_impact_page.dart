import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/smart_features_dummy_data.dart';
import '../../services/food_rescue_impact_service.dart';

class FoodRescueImpactPage extends StatelessWidget {
  const FoodRescueImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = SmartFeaturesDummyData.rescueOrders;
    final result = FoodRescueImpactService.calculate(orders);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          'Food Rescue Impact',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF7FAF7),
        foregroundColor: const Color(0xFF242B26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Food Rescue Impact Tracker',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF176B45),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Statistik makanan yang berhasil diselamatkan '
            'dari pesanan yang sudah selesai diambil.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 42,
                    color: Color(0xFF176B45),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '${result.totalRescuedPortions}',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF176B45),
                    ),
                  ),

                  Text(
                    'Porsi Makanan Terselamatkan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${result.completedOrders} pesanan selesai diambil',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Riwayat Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          for (final order in orders)
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFD9E3DC)),
              ),
              child: ListTile(
                title: Text(
                  order.productName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${order.quantity} porsi • ${order.orderId}',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Text(
                  order.isPickedUp ? 'Selesai' : 'Belum Diambil',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: order.isPickedUp
                        ? const Color(0xFF176B45)
                        : Colors.orange,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
