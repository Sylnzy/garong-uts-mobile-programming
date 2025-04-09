import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '/core/services/order_service.dart';
import 'status_order_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  List<Map<String, dynamic>> _orders = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadOrders();
  }

  Future<void> _checkAuthAndLoadOrders() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoggedIn = user != null;
    });

    if (_isLoggedIn) {
      await _loadOrderHistory();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadOrderHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get orders from OrderService with Firebase implementation
      final orders = await OrderService.getOrderHistory();

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading order history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0D1B2A),
      ),
      body:
          !_isLoggedIn
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 64,
                      color: Color(0xFF0D1B2A),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Silakan login untuk melihat riwayat pesanan.",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              )
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _orders.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Color(0xFF0D1B2A)),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada riwayat pesanan.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadOrderHistory,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      order['date'] as int,
                    );

                    return _buildOrderCard(context, order, date);
                  },
                ),
              ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    DateTime date,
  ) {
    // Tentukan jenis pengiriman (delivery atau self-pickup)
    final bool isDelivery =
        order['buyerData'] != null && order['buyerData']['isDelivery'] != null
            ? order['buyerData']['isDelivery']
            : true;

    // Tentukan waktu pengambilan untuk self-pickup (jadwal default)
    final String pickupTime =
        "Hari ini ${DateFormat('HH:mm').format(date.add(const Duration(hours: 1)))} - ${DateFormat('HH:mm').format(date.add(const Duration(hours: 2)))}";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Color(0xFF0D1B2A)),
                const SizedBox(width: 8),
                Text(
                    'Order #${order['orderId'].toString().substring(0, math.min(6, order['orderId'].toString().length))}',
                    style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'] ?? 'Unknown',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(date)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),

            // Tambahkan indikator delivery/self-pickup dengan ikon
            Row(
              children: [
                Icon(
                  isDelivery ? Icons.delivery_dining : Icons.store,
                  size: 18,
                  color: isDelivery ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isDelivery ? 'Pengiriman ke Alamat' : 'Self-Pickup di Toko',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDelivery ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),

            // Tampilkan waktu pengambilan jika self-pickup
            if (!isDelivery) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Waktu Pengambilan: $pickupTime',
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 4),
            Text(
              'Total: ${currencyFormatter.format(order['amount'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate((order['items'] as List).length, (i) {
              final item = (order['items'] as List)[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item['quantity']}x ${item['title']}'),
                    Text(
                      currencyFormatter.format(
                        (item['price'] as int) * (item['quantity'] as int),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Tambahkan informasi pembeli jika ada
            if (order['buyerData'] != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const Text(
                'Informasi Pembeli',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Nama: ${order['buyerData']['nama'] ?? '-'}'),
              Text('Email: ${order['buyerData']['email'] ?? '-'}'),
              Text('No. HP: ${order['buyerData']['hp'] ?? '-'}'),

              // Ubah tampilan alamat dengan label sesuai jenis pengiriman
              if (order['buyerData']['alamat'] != null &&
                  order['buyerData']['alamat'].toString().isNotEmpty)
                Text(
                  isDelivery
                      ? 'Alamat Pengiriman: ${order['buyerData']['alamat']}'
                      : 'Alamat Toko: ${order['buyerData']['alamat']}',
                  style: TextStyle(
                    fontWeight:
                        isDelivery ? FontWeight.normal : FontWeight.w500,
                  ),
                ),

              // Tampilkan catatan jika ada
              if (order['buyerData']['catatan'] != null &&
                  order['buyerData']['catatan'].toString().isNotEmpty)
                Text('Catatan: ${order['buyerData']['catatan']}'),
            ],

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => StatusOrderPage(
                            orderId: order['orderId'].toString().substring(
                              6,
                              12,
                            ),
                            orderDate: DateFormat(
                              'dd MMM yyyy, HH:mm',
                            ).format(date),
                            amount: (order['amount'] as int).toDouble(),
                            isDelivery:
                                order['buyerData'] != null &&
                                        order['buyerData']['isDelivery'] != null
                                    ? order['buyerData']['isDelivery']
                                    : true,
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text("Lihat Status"),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
