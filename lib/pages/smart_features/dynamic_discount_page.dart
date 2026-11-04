import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/smart_features_dummy_data.dart';
import '../../models/discount_recommendation_model.dart';
import '../../services/dynamic_discount_service.dart';

class DynamicDiscountPage extends StatefulWidget {
  const DynamicDiscountPage({super.key});

  @override
  State<DynamicDiscountPage> createState() => _DynamicDiscountPageState();
}

class _DynamicDiscountPageState extends State<DynamicDiscountPage> {
  final Map<String, String> _decisionStatus = {};
  final Map<String, int> _customDiscounts = {};

  @override
  Widget build(BuildContext context) {
    final products = SmartFeaturesDummyData.discountProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          'Dynamic Discount',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF7FAF7),
        foregroundColor: const Color(0xFF242B26),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Smart Dynamic Discount',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF176B45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rekomendasi diskon berdasarkan stok, waktu tersisa, '
            'dan kecepatan penjualan.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          for (final product in products) ...[
            _buildDiscountCard(product),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscountCard(DiscountRecommendationModel product) {
    final result = DynamicDiscountService.calculate(product);

    final status = _decisionStatus[product.productName] ?? 'Menunggu keputusan';

    final customDiscount = _customDiscounts[product.productName];

    final displayedDiscount = customDiscount ?? result.discountPercentage;

    final displayedPrice =
        product.originalPrice * (100 - displayedDiscount) / 100;

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

            const SizedBox(height: 16),

            _buildInfoRow('Harga awal', 'Rp${product.originalPrice.toInt()}'),
            _buildInfoRow('Stok tersisa', '${product.remainingStock} porsi'),
            _buildInfoRow(
              'Waktu tersisa',
              '${product.minutesUntilClosing} menit',
            ),
            _buildInfoRow('Terjual hari ini', '${product.soldToday} porsi'),

            const Divider(height: 28),

            if (result.isAvailable) ...[
              _buildInfoRow('Rekomendasi diskon', '$displayedDiscount%'),
              _buildInfoRow(
                'Harga setelah diskon',
                'Rp${displayedPrice.toInt()}',
              ),

              const SizedBox(height: 8),

              Text(
                'Status: $status',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF176B45),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _decisionStatus[product.productName] = 'Disetujui';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF176B45),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Setujui'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showEditDiscountDialog(product, displayedDiscount);
                      },
                      child: const Text('Ubah'),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _decisionStatus[product.productName] = 'Ditolak';
                        });
                      },
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                result.message,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
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
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDiscountDialog(
    DiscountRecommendationModel product,
    int currentDiscount,
  ) {
    final controller = TextEditingController(text: currentDiscount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Diskon'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Persentase diskon',
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);

                if (value == null || value < 0 || value > 30) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Diskon harus antara 0% sampai 30%.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  _customDiscounts[product.productName] = value;
                  _decisionStatus[product.productName] = 'Diubah oleh tenant';
                });

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
