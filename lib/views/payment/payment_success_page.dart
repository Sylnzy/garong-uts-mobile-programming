import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import '/core/services/order_service.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String orderId;
  final int amount;
  final Map<String, dynamic> buyerData;

  const PaymentSuccessPage({
    Key? key, 
    required this.orderId,
    required this.amount,
    required this.buyerData,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isSaving = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _saveOrderData();
  }

  Future<void> _saveOrderData() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      await OrderService.saveOrder(
        orderId: widget.orderId,
        amount: widget.amount,
        items: cartProvider.items.values.toList(),
        buyerData: widget.buyerData,
      );

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString();
      });
      print('Error saving order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isSaving 
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 20),
                  Text("Menyimpan data pesanan..."),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorMessage.isNotEmpty) ...[
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Terjadi kesalahan: $_errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pembayaran Telah Dikonfirmasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Order ID: ${widget.orderId}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Nama: ${widget.buyerData['nama']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Jumlah: Rp ${widget.amount}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B2A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    onPressed: () {
                      // Clear the cart after successful payment
                      Provider.of<CartProvider>(context, listen: false).clearCart();
                      
                      // Navigate to the home page using the correct route '/'
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

