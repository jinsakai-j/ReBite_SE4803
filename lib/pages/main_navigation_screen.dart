import 'package:flutter/material.dart';
import 'package:rebite_mobile/pages/home_pages.dart';
import 'package:rebite_mobile/pages/smart_features/smart_features_page.dart';
import 'package:rebite_mobile/pages/tenant_dashboard_screen.dart';
import 'package:rebite_mobile/pages/transaction/cart_page.dart';
import 'package:rebite_mobile/pages/transaction/order_history_page.dart';
import 'package:rebite_mobile/pages/transaction/tenant_verification_page.dart';

import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, required this.isTenant});

  final bool isTenant;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = widget.isTenant
        ? <Widget>[
            const TenantDashboardScreen(),
            const SmartFeaturesPage(),
            const TenantVerificationPage(tenantId: 'TNT001'),
            ProfileScreen(
              isTenant: true,
              onOpenOrders: () => setState(() => _selectedIndex = 2),
            ),
          ]
        : <Widget>[
            const HomePage(),
            CartPage(),
            const OrderHistoryPage(consumerId: 'CNS001'),
            ProfileScreen(
              isTenant: false,
              onOpenOrders: () => setState(() => _selectedIndex = 2),
            ),
          ];
    final labels = widget.isTenant
        ? ['Dashboard', 'Smart', 'Pesanan', 'Profil']
        : ['Home', 'Keranjang', 'Pesanan', 'Profil'];
    final icons = widget.isTenant
        ? [
            Icons.dashboard_outlined,
            Icons.insights_outlined,
            Icons.receipt_long_outlined,
            Icons.person_outline,
          ]
        : [
            Icons.home_outlined,
            Icons.shopping_cart_outlined,
            Icons.receipt_long_outlined,
            Icons.person_outline,
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF176B45),
        unselectedItemColor: const Color(0xFF718076),
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          for (var index = 0; index < labels.length; index++)
            BottomNavigationBarItem(
              icon: Icon(icons[index]),
              label: labels[index],
            ),
        ],
      ),
    );
  }
}
