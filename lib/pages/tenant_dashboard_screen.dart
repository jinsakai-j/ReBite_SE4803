import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'product_form_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  final List<Product> products = [
    Product(
      name: 'Salad fresh',
      price: 'Rp 10.000',
      stock: '5 porsi',
      imagePath: '',
    ),
    Product(
      name: 'Nasi bakar',
      price: 'Rp 15.000',
      stock: '5 porsi',
      imagePath: '',
    ),
  ];

  void _navigateToForm({Product? product, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );

    if (result != null && result is Product) {
      setState(() {
        if (index != null) {
          products[index] = result;
        } else {
          products.add(result);
        }
      });
    }
    void _deleteProduct(int index) {
      setState(() {
        products.removeAt(index);
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FAF7), // Sesuai ketentuan background
        appBar: AppBar(
          title: const Text(
            'Tenant Dashboard',
            style: TextStyle(
              color: Color(0xFF242B26),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF242B26)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Statistik
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF), // Sesuai ketentuan card
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Sesuai ketentuan radius card 12px
                  border: Border.all(
                    color: const Color(0xFFD9E3DC),
                  ), // Sesuai ketentuan border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Produk',
                          style: TextStyle(
                            color: Color(0xFF718076),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} Menu',
                          style: const TextStyle(
                            color: Color(0xFF242B26),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToForm(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF176B45,
                        ), // Sesuai ketentuan primary green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Sesuai ketentuan radius tombol 8px
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kelola Produk Tenant',
                style: TextStyle(
                  color: Color(0xFF242B26),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ListView Produk Dinamis
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // Card putih
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Radius card 12px
                      border: Border.all(
                        color: const Color(0xFFD9E3DC),
                      ), // Border sesuai
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imagePath,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 55,
                                height: 55,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(
                          color: Color(0xFF242B26),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${product.price}  •  Stok: ${product.stock}',
                          style: const TextStyle(
                            color: Color(0xFF718076),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF176B45),
                            ),
                            onPressed: () =>
                                _navigateToForm(product: product, index: index),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteProduct(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}
