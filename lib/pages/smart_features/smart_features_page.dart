import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'surplus_prediction_page.dart';
import 'food_rescue_impact_page.dart';

class SmartFeaturesPage extends StatelessWidget {
  const SmartFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          'Smart Features',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF7FAF7),
        foregroundColor: const Color(0xFF242B26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fitur Unggulan ReBite',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF176B45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan fitur pintar untuk membantu mengurangi '
            'potensi makanan surplus.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          _buildFeatureCard(
            context: context,
            icon: Icons.analytics_outlined,
            title: 'Prediksi Surplus',
            description:
                'Lihat estimasi permintaan dan potensi surplus produk.',
            page: const SurplusPredictionPage(),
          ),

          const SizedBox(height: 12),

          _buildFeatureCard(
            context: context,
            icon: Icons.eco_outlined,
            title: 'Food Rescue Impact',
            description:
                'Lihat jumlah porsi makanan yang berhasil diselamatkan.',
            page: const FoodRescueImpactPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget page,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: const Color(0xFF176B45), size: 30),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description, style: GoogleFonts.poppins(fontSize: 12)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
