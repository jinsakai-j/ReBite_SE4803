import 'package:flutter/material.dart';

import '../models/product.dart';

// Widget untuk filter kategori makanan
class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories = const ['Semua', 'Makanan', 'Minuman', 'Roti'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final selected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => onSelected(category),
              selectedColor: const Color(0xFF176B45),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFD9E3DC)),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF242B26),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Widget untuk pencarian makanan
class FoodSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const FoodSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari makanan favoritmu...',
        prefixIcon: const Icon(Icons.search, color: Color(0xFF176B45)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF176B45), width: 1.5),
        ),
      ),
    );
  }
}

// Widget untuk menampilkan kartu produk makanan
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  String formatRupiah(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  @override
  Widget build(BuildContext context) {
    final discount =
        ((product.originalPrice - product.discountPrice) /
                product.originalPrice *
                100)
            .round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9E3DC)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE7F3EA),
                        child: const Icon(
                          Icons.fastfood,
                          size: 45,
                          color: Color(0xFF176B45),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF176B45),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-$discount%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF242B26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.tenantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF647067),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatRupiah(product.originalPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      formatRupiah(product.discountPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B45),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Stok: ${product.stock} tersedia',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF647067),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
