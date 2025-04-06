import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  double _discount = 0.0;
  String _usedCoupon = '';

  void applyCoupon(String code) {
    Map<String, double> coupons = {
      'maul': 0.05,
      'naila': 0.02,
      'amel': 0.10,
    };

    setState(() {
      _discount = coupons[code.toLowerCase()] ?? 0.0;
      _usedCoupon = code;
    });

    if (_discount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kupon "$code" berhasil digunakan!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kupon tidak valid.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();
    final deliveryFee = 10000;
    final subtotal = cart.totalAmount;
    final discountAmount = (subtotal * _discount).toInt();
    final total = subtotal + deliveryFee - discountAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Daftar produk
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        'https://via.placeholder.com/100', // ganti sesuai kebutuhan
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item.title),
                      subtitle: Text('Jumlah: ${item.quantity}'),
                      trailing: Text('Rp ${item.price * item.quantity}'),
                    ),
                  );
                },
              ),
            ),

            // Kupon
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan kode kupon',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => applyCoupon(_couponController.text),
                  child: const Text("Gunakan"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ringkasan harga
            Column(
              children: [
                summaryRow("Subtotal", subtotal),
                summaryRow("Pengantaran", deliveryFee),
                if (_discount > 0) summaryRow("Diskon (${(_discount * 100).toInt()}%)", -discountAmount),
                const Divider(),
                summaryRow("Total", total, isBold: true),
              ],
            ),

            const SizedBox(height: 16),

            // Tombol Pesan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Pindah ke halaman pembayaran
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lanjut ke halaman pembayaran...")),
                  );
                },
                child: const Text("Pesan"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String title, int amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("Rp $amount", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
