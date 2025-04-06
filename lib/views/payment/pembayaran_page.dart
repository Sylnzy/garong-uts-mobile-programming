import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';

class HalamanPembayaran extends StatelessWidget {
  final Map<String, dynamic> buyerData;
  final int totalPayment;

  const HalamanPembayaran({
    Key? key,
    required this.buyerData,
    required this.totalPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Total yang harus dibayar:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${totalPayment.toString()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text('Scan QRIS untuk melakukan pembayaran:'),
            const SizedBox(height: 10),
            Image.asset(
              'assets/images/splash.png',
              height: 200,
            ), // Ganti dengan real QRIS

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pembayaran berhasil. Terima kasih!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Sudah Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}
