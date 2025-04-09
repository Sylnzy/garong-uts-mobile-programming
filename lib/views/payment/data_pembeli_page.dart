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

  // Alamat toko untuk self pickup
  final String alamatToko =
      "Jl. Raya Sukabumi No. 123, Kecamatan Cikole, Kota Sukabumi, Jawa Barat 43113";

  void _handlePesan() {
    if (_formKey.currentState!.validate()) {
      final buyerData = {
        'nama': namaController.text,
        'email': emailController.text,
        'hp': hpController.text,
        'alamat': widget.isDelivery ? alamatController.text : alamatToko,
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

              // Kondisional untuk alamat
              if (widget.isDelivery) ...[
                // Jika delivery, minta alamat pengiriman
                _buildTextField(
                  label: 'Alamat Pengiriman',
                  controller: alamatController,
                  isRequired: true,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
              ] else ...[
                // Jika self pickup, tampilkan alamat toko
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Toko (untuk Self Pickup):',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Toko Garong',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(alamatToko),
                          const SizedBox(height: 4),
                          const Text(
                            'Jam Operasional: 08.00 - 21.00 WIB',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],

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
