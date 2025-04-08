import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/services/order_service.dart';
import 'status_order_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get orders from OrderService
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
          _isLoading
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
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    order['date'] as int,
                  );

                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke Status Order Page ketika order diketuk
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
                              ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag,
                                  color: Color(0xFF0D1B2A),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Order #${order['orderId'].toString().substring(6, 12)}',
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
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
                            const Text(
                              'Items',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate((order['items'] as List).length, (
                              i,
                            ) {
                              final item = (order['items'] as List)[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item['quantity']}x ${item['title']}',
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        (item['price'] as int) *
                                            (item['quantity'] as int),
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
                              Text(
                                'Nama: ${order['buyerData']['nama'] ?? '-'}',
                              ),
                              Text(
                                'Email: ${order['buyerData']['email'] ?? '-'}',
                              ),
                              Text(
                                'No. HP: ${order['buyerData']['hp'] ?? '-'}',
                              ),
                              if (order['buyerData']['alamat'] != null &&
                                  order['buyerData']['alamat']
                                      .toString()
                                      .isNotEmpty)
                                Text('Alamat: ${order['buyerData']['alamat']}'),
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
                                            orderId: order['orderId']
                                                .toString()
                                                .substring(6, 12),
                                            orderDate: DateFormat(
                                              'dd MMM yyyy, HH:mm',
                                            ).format(date),
                                            amount:
                                                (order['amount'] as int)
                                                    .toDouble(),
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility),
                                label: const Text("Lihat Status"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
