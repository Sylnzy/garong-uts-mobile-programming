import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // Simplified with hardcoded data for now
  final bool _isLoading = false;
  final List<Map<String, dynamic>> _orders = [];
  
  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Add a demo order if needed
    _orders.add({
      'orderId': 'ORDER-123456789',
      'date': DateTime.now().millisecondsSinceEpoch,
      'amount': 150000,
      'status': 'completed',
      'items': [
        {'title': 'Beras Premium', 'quantity': 2, 'price': 75000},
      ],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
        title: const Text("Riwayat Pesanan"),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text("Belum ada riwayat pesanan.", style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final date = DateTime.fromMillisecondsSinceEpoch(order['date'] as int);
                
                return Card(
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
                            const Icon(Icons.shopping_bag, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Order #${order['orderId'].toString().substring(6, 12)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        Text(
                          'Total: ${currencyFormatter.format(order['amount'])}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Colors.blue
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const Text(
                          'Items',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(
                          (order['items'] as List).length,
                          (i) {
                            final item = (order['items'] as List)[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['quantity']}x ${item['title']}',
                                  ),
                                  Text(
                                    currencyFormatter.format(
                                      (item['price'] as int) * (item['quantity'] as int)
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
