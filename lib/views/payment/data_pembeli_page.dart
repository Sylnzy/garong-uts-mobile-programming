import 'package:flutter/material.dart';
import 'pembayaran_page.dart';
import '/providers/cart_provider.dart';

class DataPembeliPage extends StatefulWidget {
  final int totalPayment;
  final List<CartItem> items;
  final bool isDelivery;

  const DataPembeliPage({
    Key? key,
    required this.totalPayment,
    required this.items,
    required this.isDelivery,
  }) : super(key: key);

  @override
  State<DataPembeliPage> createState() => _DataPembeliPageState();
}

class _DataPembeliPageState extends State<DataPembeliPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final alamatController = TextEditingController();
  final catatanController = TextEditingController();

  void _handlePesan() {
    if (_formKey.currentState!.validate()) {
      final buyerData = {
        'nama': namaController.text,
        'email': emailController.text,
        'hp': hpController.text,
        'alamat': widget.isDelivery ? alamatController.text : '',
        'catatan': catatanController.text,
        'isDelivery': widget.isDelivery,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanPembayaran(
            buyerData: buyerData,
            totalPayment: widget.totalPayment,
            items: widget.items, // Added the missing required parameter
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Pembeli"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: hpController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              if (widget.isDelivery)
                TextFormField(
                  controller: alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              TextFormField(
                controller: catatanController,
                decoration: const InputDecoration(labelText: 'Catatan'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handlePesan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Pesan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
