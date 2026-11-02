import '../models/tenant.dart';

final List<Tenant> dummyTenants = [
  Tenant(
    id: 1,
    name: 'Warung Nusantara',
    image: 'assets/images/warung_nusantara.jpg',
    location: 'Bojongsoang, Bandung',
    openingHours: '08.00 - 21.00',
    description: 'Menyediakan berbagai makanan khas Nusantara.',
  ),
  Tenant(
    id: 2,
    name: 'Bread House',
    image: 'assets/images/bread_house.jpg',
    location: 'Dayeuhkolot, Bandung',
    openingHours: '07.00 - 20.00',
    description: 'Toko roti dengan berbagai pilihan roti dan pastry.',
  ),
  Tenant(
    id: 3,
    name: 'Fresh Drink',
    image: 'assets/images/fresh_drink.jpg',
    location: 'Bojongsoang, Bandung',
    openingHours: '09.00 - 22.00',
    description: 'Menyediakan minuman segar dari buah pilihan.',
  ),
  Tenant(
    id: 4,
    name: 'Daily Kitchen',
    image: 'assets/images/daily_kitchen.jpg',
    location: 'Buahbatu, Bandung',
    openingHours: '10.00 - 21.00',
    description: 'Menyediakan makanan praktis untuk kebutuhan sehari-hari.',
  ),
];
