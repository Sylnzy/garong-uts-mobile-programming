import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';


class HalamanPembayaran extends StatelessWidget {
  final Map<String, dynamic> buyerData;

  HalamanPembayaran({required this.buyerData});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final totalAkhir = cart.totalAmount + buyerData['biayaPengiriman'];

    return Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Total yang harus dibayar:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Rp ${totalAkhir.toString()}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            Text('Scan QRIS untuk melakukan pembayaran:'),
            SizedBox(height: 10),
            Image.asset('assets/images/splash.png', height: 200), // Ganti dengan real QRIS

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran berhasil. Terima kasih!')));
              },
              child: Text('Sudah Bayar'),
            )
          ],
        ),
      ),
    );
  }
}
