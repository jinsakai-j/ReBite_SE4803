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
      imagePath: 'assets/images/product1.jpg',
    ),
    Product(
      name: 'Nasi bakar',
      price: 'Rp 15.000',
      stock: '5 porsi',
      imagePath: 'assets/images/product1.jpg',
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
          _products[index] = result;
        } else {
          _products.add(result);
        }
      });
    }
  }
}
