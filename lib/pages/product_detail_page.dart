import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final discount = product.originalPrice > 0
        ? ((product.originalPrice - product.discountPrice) /
                  product.originalPrice *
                  100)
              .round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF242B26),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto produk
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE7F3EA),
                    child: const Icon(
                      Icons.fastfood,
                      size: 70,
                      color: Color(0xFF176B45),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan kategori
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF242B26),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F3EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: Color(0xFF176B45),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informasi harga
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD9E3DC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Harga Spesial ReBite',
                          style: TextStyle(color: Color(0xFF647067)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              formatRupiah(product.discountPrice),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF176B45),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (discount > 0)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F3EA),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$discount% OFF',
                                  style: const TextStyle(
                                    color: Color(0xFF176B45),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatRupiah(product.originalPrice),
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Informasi penjual
                  const Text(
                    'Informasi Penjual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF242B26),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD9E3DC)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFE7F3EA),
                          child: Icon(Icons.store, color: Color(0xFF176B45)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            product.tenantName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF242B26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Deskripsi
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF242B26),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF647067),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stok
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF176B45),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stok tersedia: ${product.stock}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF242B26),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
