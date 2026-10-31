import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String _selectedImagePath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price ?? '');
    _stockController = TextEditingController(text: widget.product?.stock ?? '');
    if (widget.product != null) {
      _selectedImagePath = widget.product!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF242B26),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF176B45)),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImagePath = '';
                });
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF176B45),
              ),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImagePath = '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_nameController.text.isNotEmpty) {
      final newProduct = Product(
        name: _nameController.text,
        price: _priceController.text,
        stock: _stockController.text,
        imagePath: _selectedImagePath,
      );
      Navigator.pop(context, newProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Tambah Produk' : 'Edit Produk',
          style: const TextStyle(
            color: Color(0xFF242B26),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF242B26)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _selectedImagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF176B45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
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
