import 'package:flutter/material.dart';

import '../data/dummy_products.dart';
import '../widgets/product_card.dart';
import '../widgets/food_search_bar.dart';
import '../widgets/category_filter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final filteredProducts = dummyProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      final matchesCategory =
          selectedCategory == 'Semua' || product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF7),
        elevation: 0,
        title: const Text(
          'ReBite',
          style: TextStyle(
            color: Color(0xFF176B45),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF242B26),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Halo, Selamat Datang! 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 8),

            const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF176B45), size: 18),
                SizedBox(width: 5),
                Text(
                  'Bojongsoang, Bandung',
                  style: TextStyle(color: Color(0xFF647067), fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Temukan makanan surplus dengan harga hemat!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 12),

            FoodSearchBar(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategori Makanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF242B26),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'Semua';
                      searchQuery = '';
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Color(0xFF176B45)),
                  ),
                ),
              ],
            ),

            CategoryFilter(
              selectedCategory: selectedCategory,
              onSelected: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Makanan Surplus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF242B26),
                  ),
                ),
                Text(
                  '${filteredProducts.length} produk',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF647067),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (filteredProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 45,
                        color: Color(0xFF647067),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Produk tidak ditemukan.',
                        style: TextStyle(color: Color(0xFF647067)),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 275,
                ),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  return ProductCard(
                    product: product,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.name} dipilih')),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
