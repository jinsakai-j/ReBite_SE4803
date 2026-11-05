import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/transaction_service.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  final String consumerId;

  const OrderHistoryPage({super.key, required this.consumerId});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  static const Color primaryGreen = Color(0xFF176B45);
  static const Color backgroundColor = Color(0xFFF7FAF7);
  static const Color textColor = Color(0xFF242B26);
  static const Color borderColor = Color(0xFFD9E3DC);

  String selectedFilter = 'Semua';

  final List<String> filters = [
    'Semua',
    'Diproses',
    'Siap Diambil',
    'Selesai',
    'Dibatalkan',
    'Terlambat',
  ];

  List<OrderModel> get consumerOrders {
    final orders = TransactionService.instance.orders
        .where((order) => order.consumerId == widget.consumerId)
        .toList();

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }

  List<OrderModel> get filteredOrders {
    final orders = consumerOrders;

    switch (selectedFilter) {
      case 'Diproses':
        return orders.where((order) {
          return order.status == OrderStatus.waitingPayment ||
              order.status == OrderStatus.waitingConfirmation;
        }).toList();

      case 'Siap Diambil':
        return orders.where((order) {
          return order.status == OrderStatus.readyForPickup;
        }).toList();

      case 'Selesai':
        return orders.where((order) {
          return order.status == OrderStatus.completed;
        }).toList();

      case 'Dibatalkan':
        return orders.where((order) {
          return order.status == OrderStatus.cancelled;
        }).toList();

      case 'Terlambat':
        return orders.where((order) {
          return order.status == OrderStatus.late;
        }).toList();

      default:
        return orders;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }

  String _twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  String _formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/'
        '${_twoDigits(date.month)}/${date.year} '
        '${_twoDigits(date.hour)}:'
        '${_twoDigits(date.minute)}';
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return Colors.orange.shade800;
      case OrderStatus.waitingConfirmation:
        return Colors.blue.shade700;
      case OrderStatus.readyForPickup:
        return primaryGreen;
      case OrderStatus.completed:
        return primaryGreen;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
      case OrderStatus.late:
        return Colors.deepOrange.shade700;
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return Icons.access_time;
      case OrderStatus.waitingConfirmation:
        return Icons.hourglass_top;
      case OrderStatus.readyForPickup:
        return Icons.shopping_bag_outlined;
      case OrderStatus.completed:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.late:
        return Icons.warning_amber_outlined;
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: const Color(0xFFE6F2E9),
              backgroundColor: Colors.white,
              side: BorderSide(color: isSelected ? primaryGreen : borderColor),
              labelStyle: TextStyle(
                color: isSelected ? primaryGreen : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openOrderDetail(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => OrderDetailPage(orderId: order.orderId),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildOrderCard(OrderModel order) {
    final Color statusColor = _statusColor(order.status);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: () => _openOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.orderId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(_statusIcon(order.status), size: 16, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              Text(
                order.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '${order.quantity} porsi',
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 6),

              Text(
                'Metode: ${order.paymentMethodLabel}',
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 6),

              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),

              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Rp${_formatPrice(order.totalPrice)}',
                    style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: primaryGreen,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Pesanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'Semua'
                  ? 'Kamu belum memiliki riwayat transaksi.'
                  : 'Tidak ada pesanan dengan filter '
                        '$selectedFilter.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderModel> orders = filteredOrders;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          _buildFilterChips(),

          const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              color: primaryGreen,
              onRefresh: () async {
                setState(() {});
              },
              child: orders.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 400, child: _buildEmptyState()),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(orders[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
