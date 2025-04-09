import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/views/pages/delivery_tracking_page.dart';
import '/views/pages/lokasi_page.dart'; // Tambahkan import untuk LokasiPage
import '/views/pages/store_location_map_page.dart';

class StatusOrderPage extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final double amount;
  final bool isDelivery;

  const StatusOrderPage({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.amount,
    this.isDelivery = true,
  }) : super(key: key);

  @override
  _StatusOrderPageState createState() => _StatusOrderPageState();
}

class _StatusOrderPageState extends State<StatusOrderPage> {
  int currentStep = 0;
  Timer? _timer;

  // Koordinat toko untuk map (contoh koordinat)
  final double storeLat = -6.925020; // Latitude lokasi toko
  final double storeLng = 106.929755; // Longitude lokasi toko

  late final List<Map<String, String>> steps;

  @override
  void initState() {
    super.initState();

    // Tentukan steps berdasarkan jenis pengiriman
    steps = widget.isDelivery ? _getDeliverySteps() : _getPickupSteps();

    // Update timer dari 10 detik menjadi 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentStep < steps.length - 1) {
        setState(() {
          currentStep++;
        });
      } else {
        timer.cancel(); // stop when done
      }
    });
  }

  // Steps untuk pengiriman (delivery)
  List<Map<String, String>> _getDeliverySteps() {
    return [
      {
        "time": "9:30 AM",
        "title": "Pesanan Dibuat",
        "desc": "Pesanan Anda telah dibuat untuk pengiriman ke alamat.",
      },
      {
        "time": "9:35 AM",
        "title": "Menunggu Konfirmasi",
        "desc": "Pesanan Anda sedang menunggu konfirmasi toko.",
      },
      {
        "time": "9:55 AM",
        "title": "Dikonfirmasi",
        "desc":
            "Pesanan Anda telah dikonfirmasi, sedang disiapkan untuk pengiriman.",
      },
      {
        "time": "10:30 AM",
        "title": "Dalam Pengiriman",
        "desc": "Produk Anda sedang dalam perjalanan ke alamat tujuan.",
      },
      {
        "time": "10:45 AM",
        "title": "Terkirim",
        "desc": "Pesanan Anda telah diterima di alamat tujuan.",
      },
    ];
  }

  // Steps untuk pengambilan sendiri (self-pickup)
  List<Map<String, String>> _getPickupSteps() {
    // Hitung waktu pengambilan (2 jam dari sekarang)
    final pickupTime = DateTime.now().add(const Duration(hours: 2));
    final formattedPickupTime =
        "${pickupTime.hour.toString().padLeft(2, '0')}:${pickupTime.minute.toString().padLeft(2, '0')}";

    return [
      {
        "time": "9:30 AM",
        "title": "Pesanan Dibuat",
        "desc": "Pesanan Anda telah dibuat untuk diambil di toko.",
      },
      {
        "time": "9:35 AM",
        "title": "Konfirmasi Toko",
        "desc": "Toko sedang mengonfirmasi ketersediaan barang pesanan Anda.",
      },
      {
        "time": "9:45 AM",
        "title": "Pesanan Disiapkan",
        "desc": "Barang-barang pesanan Anda sedang disiapkan oleh staf toko.",
      },
      {
        "time": "10:15 AM",
        "title": "Siap Diambil",
        "desc":
            "Pesanan Anda siap diambil di toko. Silakan datang ke kasir dan tunjukkan ID pesanan.",
      },
      {
        "time": "12:00 PM",
        "title": "Batas Waktu Pengambilan",
        "desc":
            "Harap ambil pesanan Anda sebelum pukul $formattedPickupTime. Lewat dari waktu tersebut, pesanan akan dibatalkan.",
      },
    ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Ubah fungsi _openStoreLocation
  void _openStoreLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StoreLocationMapPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDelivery ? "Status Pengiriman" : "Status Pesanan Pickup",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Order info section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${widget.orderId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              currentStep == steps.length - 1
                                  ? Colors.green
                                  : (currentStep >= steps.length - 2 &&
                                      !widget.isDelivery)
                                  ? Colors
                                      .orange // Warna khusus untuk 'Siap Diambil' pada self-pickup
                                  : Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentStep == steps.length - 1
                              ? widget.isDelivery
                                  ? "Terkirim"
                                  : "Batas Waktu"
                              : (currentStep == steps.length - 2 &&
                                  !widget.isDelivery)
                              ? "Siap Diambil"
                              : "Dalam Proses",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Tanggal: ${widget.orderDate}"),
                  Text("Total: Rp ${widget.amount.toStringAsFixed(0)}"),

                  // Tambahkan indikator metode pengiriman
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        widget.isDelivery ? Icons.delivery_dining : Icons.store,
                        size: 18,
                        color: widget.isDelivery ? Colors.blue : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.isDelivery
                            ? "Pengiriman ke Alamat"
                            : "Self-Pickup di Toko",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              widget.isDelivery ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  // Tambahkan informasi khusus untuk self-pickup
                  if (!widget.isDelivery && currentStep >= 3) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Informasi Pengambilan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Silakan ambil pesanan Anda di kasir toko dengan menunjukkan ID pesanan ini.",
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Batas waktu pengambilan: ${steps.last['time']}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status progress section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: steps.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    bool isCompleted = index <= currentStep;
                    bool isCurrentStep = index == currentStep;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['time']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color:
                                    isCompleted
                                        ? (!widget.isDelivery &&
                                                index == steps.length - 1)
                                            ? Colors
                                                .orange // Warna khusus untuk batas waktu pickup
                                            : Colors.green
                                        : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    step['title']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isCompleted
                                              ? (!widget.isDelivery &&
                                                      index == steps.length - 1)
                                                  ? Colors
                                                      .orange // Warna khusus untuk teks batas waktu
                                                  : (isCurrentStep
                                                      ? Colors.blue
                                                      : Colors.black)
                                              : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step['desc']!,
                                    style: TextStyle(
                                      color:
                                          isCompleted
                                              ? Colors.black87
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isCompleted)
                              Icon(
                                isCurrentStep
                                    ? Icons.radio_button_checked
                                    : Icons.check_circle,
                                color:
                                    (!widget.isDelivery &&
                                            index == steps.length - 1)
                                        ? Colors
                                            .orange // Warna khusus untuk ikon batas waktu
                                        : (isCurrentStep
                                            ? Colors.blue
                                            : Colors.green),
                                size: 20,
                              ),
                          ],
                        ),
                        if (index < steps.length - 1)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            height: 30,
                            width: 2,
                            color:
                                index < currentStep
                                    ? Colors.green
                                    : Colors.grey.shade300,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      // Update tombol di bawah untuk menampilkan beda UI untuk delivery/pickup
      bottomNavigationBar:
          widget.isDelivery
              ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DeliveryTrackingPage(
                              orderId: widget.orderId,
                              driverName: "Budi Santoso",
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1C2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lihat Lokasi Driver",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: _openStoreLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F1C2E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lihat Lokasi Toko",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
    );
  }
}
