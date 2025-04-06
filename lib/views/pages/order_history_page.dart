import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary mock data - replace with actual data from database
    final List<Map<String, dynamic>> orders = [
      {
        'orderId': '001',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'total': 150000,
        'items': [
          {'name': 'Produk 1', 'quantity': 2, 'price': 50000},
          {'name': 'Produk 2', 'quantity': 1, 'price': 50000},
        ],
        'delivery': true,
        'deliveryFee': 10000,
        'discount': 10000,
      },
      // Add more mock orders as needed
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: const Text("Riwayat Pesanan"),
        backgroundColor: Colors.orange,
      ),
      body:
          orders.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.orange),
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
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
                  final currencyFormat = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        _showOrderDetail(context, order);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order['orderId']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(order['date']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Belanja:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(order['total']),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
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

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Detail Pesanan #${order['orderId']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Item yang dibeli:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order['items'].map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']} (${item['quantity']}x)',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            currencyFormat.format(
                              item['price'] * item['quantity'],
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 32),
                  _buildPriceRow(
                    'Subtotal',
                    _calculateSubtotal(order['items']),
                  ),
                  if (order['delivery'])
                    _buildPriceRow('Biaya Pengiriman', order['deliveryFee']),
                  if (order['discount'] > 0)
                    _buildPriceRow('Diskon', -order['discount']),
                  const Divider(height: 16),
                  _buildPriceRow('Total', order['total'], isTotal: true),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceRow(String label, int amount, {bool isTotal = false}) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSubtotal(List<dynamic> items) {
    return items.fold(
      0,
      (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)),
    );
  }
}
