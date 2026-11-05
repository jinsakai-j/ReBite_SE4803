import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../routes/app_routes.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isTenant,
    required this.onOpenOrders,
  });

  final bool isTenant;
  final VoidCallback onOpenOrders;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _addresses = [
    'Rumah — Bandung, Jawa Barat',
    'Kantor — Jl. Asia Afrika No. 8, Bandung',
  ];

  late String _name = widget.isTenant ? 'ReBite Tenant' : 'Andi Pratama';
  late String _email = widget.isTenant
      ? 'tenant@rebite.com'
      : 'pembeli@rebite.com';
  String _phone = '081234567890';
  String _address = 'Bandung, Jawa Barat';
  Uint8List? _photoBytes;

  Future<void> _editProfile() async {
    final updated = await Navigator.push<ProfileDetails>(
      context,
      MaterialPageRoute<ProfileDetails>(
        builder: (_) =>
            EditProfileScreen(name: _name, email: _email, phone: _phone),
      ),
    );

    if (updated == null || !mounted) return;
    setState(() {
      _name = updated.name;
      _email = updated.email;
      _phone = updated.phone;
    });
  }

  Future<void> _changePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto tidak dapat dibuka: ${error.message}')),
      );
    }
  }

  Future<void> _editAddress() async {
    final controller = TextEditingController(text: _address);
    final updatedAddress = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alamat Saya'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final address in _addresses)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(address),
                  onTap: () =>
                      Navigator.pop(dialogContext, address.split(' — ').last),
                ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Alamat utama'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim().isEmpty ? null : controller.text.trim(),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (updatedAddress == null || !mounted) return;
    setState(() {
      _address = updatedAddress;
      if (!_addresses.any((item) => item.endsWith(updatedAddress))) {
        _addresses.add('Alamat — $updatedAddress');
      }
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7FAF7),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFFE6F2E9),
            backgroundImage: _photoBytes == null
                ? null
                : MemoryImage(_photoBytes!),
            child: _photoBytes == null
                ? Icon(
                    widget.isTenant ? Icons.storefront : Icons.person,
                    size: 42,
                    color: const Color(0xFF176B45),
                  )
                : null,
          ),
          Center(
            child: TextButton.icon(
              onPressed: _changePhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Ganti Foto Profil'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            _email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF718076)),
          ),
          Center(
            child: Chip(
              label: Text(widget.isTenant ? 'Penjual' : 'Pembeli'),
              avatar: Icon(widget.isTenant ? Icons.store : Icons.shopping_bag),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Nomor Telepon'),
              subtitle: Text(_phone),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: _editProfile,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Alamat Saya'),
              subtitle: Text(_address),
              onTap: _editAddress,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Riwayat Pesanan'),
              onTap: widget.onOpenOrders,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Bantuan'),
              onTap: () => _showInfo(
                'Bantuan ReBite',
                'Hubungi tim ReBite untuk bantuan penggunaan aplikasi.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang ReBite'),
              onTap: () => _showInfo(
                'Tentang ReBite',
                'ReBite membantu mengurangi food waste melalui makanan surplus.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
