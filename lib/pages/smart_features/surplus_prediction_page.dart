import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/smart_features_dummy_data.dart';
import '../../models/surplus_prediction_model.dart';
import '../../services/surplus_prediction_service.dart';

class SurplusPredictionPage extends StatelessWidget {
  const SurplusPredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = SmartFeaturesDummyData.surplusProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          'Prediksi Surplus',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF7FAF7),
        foregroundColor: const Color(0xFF242B26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Smart Surplus Prediction',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF176B45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat estimasi permintaan dan potensi makanan surplus '
            'berdasarkan riwayat penjualan.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          if (products.isEmpty)
            const Center(child: Text('Belum ada data produk.')),

          for (final product in products) ...[
            _buildProductCard(product),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(SurplusPredictionModel product) {
    final result = SurplusPredictionService.calculate(product);

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF242B26),
              ),
            ),
            const SizedBox(height: 4),

            Text(
              '${product.category} • ${product.salesDay}, ${product.salesTime}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(height: 16),

            _buildInfoRow(
              'Jumlah produksi',
              '${product.producedQuantity} porsi',
            ),
            _buildInfoRow('Stok saat ini', '${product.currentStock} porsi'),
            _buildInfoRow(
              'Jumlah data histori',
              '${product.salesHistory.length} catatan',
            ),

            const Divider(height: 28),

            if (result.isAvailable) ...[
              _buildInfoRow(
                'Estimasi permintaan',
                '${result.estimatedDemand} porsi',
              ),
              _buildInfoRow(
                'Potensi surplus',
                '${result.potentialSurplus} porsi',
              ),
              _buildInfoRow(
                'Saran produksi berikutnya',
                '${result.recommendedProduction} porsi',
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF8A5A00),
                  ),
                ),
              ),
            ],

            if (result.isAvailable) ...[
              const SizedBox(height: 12),
              Text(
                result.message,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF242B26),
            ),
          ),
        ],
      ),
    );
  }
}
