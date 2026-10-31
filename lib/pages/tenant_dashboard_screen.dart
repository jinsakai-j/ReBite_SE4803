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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
