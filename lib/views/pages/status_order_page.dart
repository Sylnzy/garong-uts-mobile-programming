import 'dart:async';
import 'package:flutter/material.dart';
import '/views/pages/delivery_tracking_page.dart';

class StatusOrderPage extends StatefulWidget {
  final String orderId;
  final String orderDate;
  final double amount;

  const StatusOrderPage({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.amount,
  }) : super(key: key);

  @override
  _StatusOrderPageState createState() => _StatusOrderPageState();
}

class _StatusOrderPageState extends State<StatusOrderPage> {
  int currentStep = 0;
  Timer? _timer;

  final List<Map<String, String>> steps = [
    {
      "time": "9:30 AM",
      "title": "Pesanan Dibuat",
      "desc": "Pesanan Anda telah dibuat untuk pengiriman.",
    },
    {
      "time": "9:35 AM",
      "title": "Menunggu",
      "desc":
          "Pesanan Anda sedang menunggu konfirmasi, akan dikonfirmasi dalam 5 menit.",
    },
    {
      "time": "9:55 AM",
      "title": "Dikonfirmasi",
      "desc": "Pesanan Anda telah dikonfirmasi, akan dikirim dalam 20 menit.",
    },
    {
      "time": "10:30 AM",
      "title": "Diproses",
      "desc": "Produk Anda sedang diproses untuk pengiriman tepat waktu.",
    },
    {
      "time": "10:45 AM",
      "title": "Terkirim",
      "desc":
          "Paket Anda telah diterima oleh Anda sendiri atau oleh seseorang.",
    },
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Status Order"),
        backgroundColor: const Color(0xFF0F1C2E),
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
                                  : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentStep == steps.length - 1
                              ? "Selesai"
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
                                        ? Colors.green
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
                                              ? Colors.black
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
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
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
      // Update the button at the bottom that launches the tracking page
      bottomNavigationBar: Padding(
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
