import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController _originalPriceController;
  late TextEditingController _stockController;
  String _selectedImagePath = '';
  String _selectedCategory = 'Makanan';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product?.name ?? '');

    _priceController = TextEditingController(text: widget.product?.price ?? '');
    _originalPriceController = TextEditingController(
      text: widget.product?.originalPrice.isNotEmpty == true
          ? widget.product!.originalPrice
          : widget.product?.price ?? '',
    );

    _stockController = TextEditingController(text: widget.product?.stock ?? '');

    if (widget.product != null) {
      _selectedImagePath = widget.product!.imagePath;
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();

    _originalPriceController.dispose();

    _stockController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<String>(
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
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF176B45),
              ),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || source == null) return;

    try {
      if (source == 'camera') {
        final imagePath = await Navigator.push<String>(
          context,
          MaterialPageRoute<String>(
            builder: (_) => const ProductCameraScreen(),
          ),
        );

        if (imagePath != null && mounted) {
          setState(() => _selectedImagePath = imagePath);
        }
      } else {
        final image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          imageQuality: 85,
        );

        if (image != null && mounted) {
          final imageValue = await _imageValue(image);

          setState(() => _selectedImagePath = imageValue);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto tidak dapat dibuka.')),
        );
      }
    }
  }

  Future<String> _imageValue(XFile image) async {
    if (kIsWeb) {
      return 'data:image/jpeg;base64,'
          '${base64Encode(await image.readAsBytes())}';
    }

    return image.path;
  }

  Widget _imagePreview() {
    if (_selectedImagePath.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        color: const Color(0xFFE6F2E9),
        child: const Icon(
          Icons.add_a_photo_outlined,
          size: 36,
          color: Color(0xFF176B45),
        ),
      );
    }
    if (_selectedImagePath.startsWith('http')) {
      return Image.network(
        _selectedImagePath,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (_selectedImagePath.startsWith('data:image/')) {
      return Image.memory(
        base64Decode(_selectedImagePath.split(',').last),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if (kIsWeb) return _imagePlaceholder();

    return Image.file(
      File(_selectedImagePath),
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() => Container(
    width: 120,
    height: 120,
    color: const Color(0xFFE6F2E9),
    child: const Icon(
      Icons.image_not_supported_outlined,
      size: 36,
      color: Color(0xFF718076),
    ),
  );

  void _saveProduct() {
    final originalPrice = _parsePrice(_originalPriceController.text);

    final discountPrice = _parsePrice(_priceController.text);

    if (_nameController.text.trim().isNotEmpty &&
        originalPrice > 0 &&
        discountPrice > 0 &&
        discountPrice <= originalPrice) {
      final newProduct = Product(
        name: _nameController.text,
        price: _priceController.text,
        originalPrice: _originalPriceController.text,
        stock: _stockController.text,
        imagePath: _selectedImagePath,
        category: _selectedCategory,
      );

      Navigator.pop(context, newProduct);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Isi nama dan harga dengan benar. '
            'Harga diskon harus lebih kecil atau sama dengan harga awal.',
          ),
        ),
      );
    }
  }

  int _parsePrice(String value) =>
      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  int get _discountPercentage {
    final original = _parsePrice(_originalPriceController.text);

    final discount = _parsePrice(_priceController.text);

    if (original == 0 || discount > original) return 0;

    return ((original - discount) / original * 100).round();
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
                      child: _imagePreview(),
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

            const SizedBox(height: 24),

            const Text(
              'Nama Produk',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama produk',
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: const [
                DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                DropdownMenuItem(value: 'Roti', child: Text('Roti')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Harga Awal',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _originalPriceController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Contoh: 25000',
                prefixText: 'Rp ',
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Harga Diskon',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Harga setelah diskon',
                prefixText: 'Rp ',
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Diskon: $_discountPercentage%',
              style: const TextStyle(
                color: Color(0xFF176B45),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Stok',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF242B26),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _stockController,
              decoration: InputDecoration(
                hintText: 'Contoh: 10 porsi',
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9E3DC)),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF176B45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Produk',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCameraScreen extends StatefulWidget {
  const ProductCameraScreen({super.key});

  @override
  State<ProductCameraScreen> createState() => _ProductCameraScreenState();
}

class _ProductCameraScreenState extends State<ProductCameraScreen> {
  CameraController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'Kamera tidak ditemukan.');
      }

      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _controller = controller);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final image = await controller.takePicture();

      final imageValue = kIsWeb
          ? 'data:image/jpeg;base64,'
                '${base64Encode(await image.readAsBytes())}'
          : image.path;

      if (mounted) {
        Navigator.pop(context, imageValue);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $error')));
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Foto Produk')),
      body: _error != null
          ? Center(child: Text('Kamera tidak dapat dibuka.\n$_error'))
          : controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: Center(child: CameraPreview(controller))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FloatingActionButton.large(
                    onPressed: _takePicture,
                    backgroundColor: const Color(0xFF176B45),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
    );
  }
}
