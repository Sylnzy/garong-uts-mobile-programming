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
          builder:
              (context) => HalamanPembayaran(
                buyerData: buyerData,
                totalPayment: widget.totalPayment,
                items: widget.items,
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
        centerTitle: true,
        backgroundColor: const Color(0xFF0F1C2E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Nama',
                controller: namaController,
                isRequired: true,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Email',
                controller: emailController,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'No. HP',
                controller: hpController,
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              if (widget.isDelivery)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      label: 'Alamat',
                      controller: alamatController,
                      isRequired: true,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Tampilkan status pengiriman yang dipilih
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isDelivery ? Icons.delivery_dining : Icons.store,
                      color: const Color(0xFF0F1C2E),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isDelivery
                          ? "Pengiriman ke Alamat"
                          : "Self Pickup di Toko",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(
                label: 'Catatan',
                controller: catatanController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _handlePesan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1C2E),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  "Pesan",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator:
              isRequired
                  ? (value) => value!.isEmpty ? 'Wajib diisi' : null
                  : null,
        ),
      ],
    );
  }
}
