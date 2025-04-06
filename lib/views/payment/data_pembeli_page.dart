import 'package:flutter/material.dart';
import 'pembayaran_page.dart';

class DataPembeliPage extends StatefulWidget {
  @override
  _DataPembeliPageState createState() => _DataPembeliPageState();
}

class _DataPembeliPageState extends State<DataPembeliPage> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final alamatController = TextEditingController();
  final catatanController = TextEditingController();

  String metodePengiriman = 'Delivery';
  int biayaPengiriman = 10000;

  void _handlePesan() {
    if (_formKey.currentState!.validate()) {
      final buyerData = {
        'nama': namaController.text,
        'email': emailController.text,
        'hp': hpController.text,
        'alamat': alamatController.text,
        'catatan': catatanController.text,
        'pengiriman': metodePengiriman,
        'biayaPengiriman': biayaPengiriman,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HalamanPembayaran(buyerData: buyerData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data Pembeli")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: namaController, decoration: InputDecoration(labelText: 'Nama'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: hpController, decoration: InputDecoration(labelText: 'No. HP'), validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
              TextFormField(controller: alamatController, decoration: InputDecoration(labelText: 'Alamat'), maxLines: 3, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),

              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: metodePengiriman,
                items: ['Delivery', 'Self Pickup'].map((metode) {
                  return DropdownMenuItem(value: metode, child: Text(metode));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    metodePengiriman = value!;
                    biayaPengiriman = metodePengiriman == 'Delivery' ? 10000 : 0;
                  });
                },
                decoration: InputDecoration(labelText: 'Metode Pengiriman'),
              ),

              TextFormField(controller: catatanController, decoration: InputDecoration(labelText: 'Catatan'), maxLines: 2),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handlePesan,
                child: Text('Pesan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
