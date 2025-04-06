import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String selectedMethod = 'Pick-Up';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: ${user?.displayName ?? 'User'}"),
            Text("Email: ${user?.email ?? '-'}"),
            const SizedBox(height: 20),
            const Text("Metode Pengambilan:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedMethod,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'Pick-Up', child: Text('Pick-Up')),
                DropdownMenuItem(value: 'Delivery', child: Text('Delivery')),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/payment-success');
                },
                child: const Text('Selesai Bayar'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
