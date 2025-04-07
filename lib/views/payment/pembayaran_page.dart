import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '/providers/cart_provider.dart';
import '/core/services/midtrans_service.dart';
import 'payment_success_page.dart';

class HalamanPembayaran extends StatefulWidget {
  final Map<String, dynamic> buyerData;
  final int totalPayment;
  final List<CartItem> items;

  const HalamanPembayaran({
    super.key,
    required this.buyerData,
    required this.totalPayment,
    required this.items,
  });

  @override
  State<HalamanPembayaran> createState() => _HalamanPembayaranState();
}

enum PaymentMethod { qris, bca, bni, mandiri }

class _HalamanPembayaranState extends State<HalamanPembayaran> {
  bool isLoading = false; // Changed from true to false so we start at method selection
  bool isError = false;
  String errorMessage = '';
  String? qrCodeUrl;
  String? orderId;
  Map<String, dynamic>? paymentData;
  Timer? _statusCheckTimer;
  int _secondsRemaining = 300; // 5 minutes countdown
  Timer? _countdownTimer;
  PaymentMethod? _selectedPaymentMethod; // Changed to nullable to indicate no selection
  bool _paymentMethodSelected = false; // New flag to track if method is selected
  
  @override
  void initState() {
    super.initState();
    // Don't generate payment yet - wait for method selection
    // Don't start countdown yet
    
    // Create order ID right away, though
    orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // Select payment method and begin payment generation
  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
      _paymentMethodSelected = true;
    });
    
    _generatePayment();
    _startCountdown();
    _startPaymentStatusCheck();
  }
  
  // Back to method selection
  void _backToMethodSelection() {
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    
    setState(() {
      _paymentMethodSelected = false;
      _selectedPaymentMethod = null;
      isLoading = false;
      isError = false;
    });
  }
  
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _countdownTimer?.cancel();
          // Payment expired - you might want to regenerate or show a message
        }
      });
    });
  }

  String get _formattedCountdown {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generatePayment() async {
    if (_selectedPaymentMethod == PaymentMethod.qris) {
      await _generateQRCode();
    } else {
      await _generateVirtualAccount();
    }
  }

  Future<void> _generateQRCode() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      try {
        // Call actual Midtrans API
        final result = await MidtransService.generateQRCode(
          orderId: orderId!,
          grossAmount: widget.totalPayment,
          name: widget.buyerData['nama'] ?? 'Customer',
          phone: widget.buyerData['hp'] ?? '',
          email: widget.buyerData['email'],
          address: widget.buyerData['alamat'],
        );

        setState(() {
          paymentData = result;
          // Find QR code URL from actions
          if (result['actions'] != null) {
            final actions = result['actions'] as List;
            final qrAction = actions.firstWhere(
              (action) => action['name'] == 'generate-qr-code',
              orElse: () => {'url': ''},
            );
            qrCodeUrl = qrAction['url'];
          }
          
          isLoading = false;
        });
      } catch (e) {
        // Use a logging framework instead of print in production
        debugPrint("Error calling Midtrans API: $e");
        
        // Fallback to demo QR code for testing
        setState(() {
          qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=Payment-$widget.totalPayment-$orderId";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _generateVirtualAccount() async {
    String bankCode;
    switch (_selectedPaymentMethod) {
      case PaymentMethod.bca:
        bankCode = 'bca';
        break;
      case PaymentMethod.bni:
        bankCode = 'bni';
        break;
      case PaymentMethod.mandiri:
        bankCode = 'mandiri';
        break;
      default:
        bankCode = 'bca';
    }

    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      try {
        // Call actual Midtrans API
        final result = await MidtransService.generateVirtualAccount(
          orderId: orderId!,
          grossAmount: widget.totalPayment,
          name: widget.buyerData['nama'] ?? 'Customer',
          phone: widget.buyerData['hp'] ?? '',
          email: widget.buyerData['email'],
          address: widget.buyerData['alamat'],
          bankCode: bankCode,
        );

        setState(() {
          paymentData = result;
          isLoading = false;
        });
      } catch (e) {
        // Use a logging framework instead of print in production
        debugPrint("Error calling Midtrans API: $e");
        
        // Fallback to demo data for testing
        setState(() {
          // Generate random VA number based on bank and orderId for testing
          String randomVA;
          switch (bankCode) {
            case 'bca':
              randomVA = '1234567890${orderId!.hashCode.abs() % 100}';
              break;
            case 'bni':
              randomVA = '9876543210${orderId!.hashCode.abs() % 100}';
              break;
            case 'mandiri':
              randomVA = '8888${orderId!.hashCode.abs() % 10000}';
              break;
            default:
              randomVA = '1234567890';
          }
          
          paymentData = {
            'va_numbers': [{'va_number': randomVA}],
            'bill_key': '${bankCode}_${orderId!.hashCode.abs()}',
          };
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = e.toString();
      });
    }
  }

  void _startPaymentStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // // In a real app, we would check with Midtrans API
      // // But for demo purposes, let's simulate a successful payment after 5-10 seconds
      // if (_secondsRemaining == 290) { // After ~10 seconds of starting the payment
      //   _statusCheckTimer?.cancel();
      //   _countdownTimer?.cancel();
        
      //   // Navigate to success page
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => PaymentSuccessPage(
      //         orderId: orderId!,
      //         amount: widget.totalPayment,
      //         buyerData: widget.buyerData,
      //       ),
      //     ),
      //   );
      // }
      
      // The real Midtrans implementation would be:
      
      final statusResponse = await MidtransService.checkTransactionStatus(orderId!);
      
      if (statusResponse['transaction_status'] == 'settlement' || 
          statusResponse['transaction_status'] == 'capture') {
        _statusCheckTimer?.cancel();
        _countdownTimer?.cancel();
        
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              orderId: orderId!,
              amount: widget.totalPayment,
              buyerData: widget.buyerData,
            ),
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nomor rekening disalin!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Metode Pembayaran:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              RadioListTile<PaymentMethod>(
                title: const Text('QRIS (Scan QR Code)'),
                subtitle: const Text('GoPay, OVO, DANA, LinkAja, dll'),
                value: PaymentMethod.qris,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) _selectPaymentMethod(value);
                },
              ),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                title: const Text('Virtual Account BCA'),
                value: PaymentMethod.bca,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) _selectPaymentMethod(value);
                },
              ),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                title: const Text('Virtual Account BNI'),
                value: PaymentMethod.bni,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) _selectPaymentMethod(value);
                },
              ),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                title: const Text('Virtual Account Mandiri'),
                value: PaymentMethod.mandiri,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) _selectPaymentMethod(value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildQRISPayment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // withOpacity(0.2) replacement
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Scan QRIS berikut untuk melakukan pembayaran:',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Kode berlaku selama: $_formattedCountdown',
            style: TextStyle(
              color: _secondsRemaining < 60 ? Colors.red : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          if (qrCodeUrl != null && qrCodeUrl!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                qrCodeUrl!,
                height: 280,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    children: [
                      const Icon(Icons.error_outline, size: 60),
                      const SizedBox(height: 10),
                      const Text('Gagal memuat QR code'),
                      const SizedBox(height: 10),
                      Text(error.toString()),
                    ],
                  );
                },
              ),
            )
          else
            const Text(
              'QR Code tidak tersedia',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildVirtualAccountPayment() {
    String bankName = '';
    String vaNumber = '';
    
    switch (_selectedPaymentMethod) {
      case PaymentMethod.bca:
        bankName = 'BCA';
        break;
      case PaymentMethod.bni:
        bankName = 'BNI';
        break;
      case PaymentMethod.mandiri:
        bankName = 'Mandiri';
        break;
      default:
        bankName = '';
    }
    
    // Extract VA number from paymentData
    if (paymentData != null) {
      if (_selectedPaymentMethod != PaymentMethod.mandiri) {
        // For BCA and BNI
        if (paymentData!['va_numbers'] != null && 
            (paymentData!['va_numbers'] as List).isNotEmpty) {
          vaNumber = paymentData!['va_numbers'][0]['va_number'] ?? '';
        }
      } else {
        // For Mandiri
        vaNumber = paymentData!['bill_key'] ?? '';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // withOpacity(0.2) replacement
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Virtual Account $bankName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Selesaikan pembayaran dalam: $_formattedCountdown',
            style: TextStyle(
              color: _secondsRemaining < 60 ? Colors.red : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.credit_card, size: 28),
              const SizedBox(width: 8),
              const Text(
                'No. Virtual Account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    vaNumber,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(vaNumber),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            'Rp ${widget.totalPayment.toString()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    if (_selectedPaymentMethod == PaymentMethod.qris) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(26), // withOpacity(0.1) replacement
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withAlpha(76)), // withOpacity(0.3) replacement
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Cara Melakukan Pembayaran QRIS:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text('1. Buka aplikasi e-wallet (GoPay, OVO, DANA, dll)'),
            Text('2. Pilih fitur scan QR code'),
            Text('3. Scan QR code di atas'),
            Text('4. Periksa detail pembayaran'),
            Text('5. Konfirmasi dan selesaikan pembayaran'),
          ],
        ),
      );
    } else {
      String bankName = '';
      switch (_selectedPaymentMethod) {
        case PaymentMethod.bca:
          bankName = 'BCA';
          break;
        case PaymentMethod.bni:
          bankName = 'BNI';
          break;
        case PaymentMethod.mandiri:
          bankName = 'Mandiri';
          break;
        default:
          bankName = '';
      }
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(26), // withOpacity(0.1) replacement
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withAlpha(76)), // withOpacity(0.3) replacement
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cara Melakukan Pembayaran Virtual Account $bankName:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text('1. Login ke Mobile Banking atau Internet Banking'),
            const Text('2. Pilih menu Pembayaran/Transfer Virtual Account'),
            Text('3. Masukkan nomor Virtual Account $bankName di atas'),
            const Text('4. Periksa detail pembayaran'),
            const Text('5. Konfirmasi dan selesaikan pembayaran'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        // Add back button if payment method is selected
        leading: _paymentMethodSelected ? 
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backToMethodSelection,
          ) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Total yang harus dibayar:', 
              style: TextStyle(fontSize: 16)
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${widget.totalPayment.toString()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            if (!_paymentMethodSelected)
              _buildPaymentMethodSelection()
            else if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memproses pembayaran...'),
                  ],
                ),
              )
            else if (isError)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(
                      'Error: $errorMessage',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _generatePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _selectedPaymentMethod == PaymentMethod.qris
                          ? _buildQRISPayment()
                          : _buildVirtualAccountPayment(),
                          
                      const SizedBox(height: 20),
                      const Text(
                        'Pembayaran akan otomatis terverifikasi',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Mohon tunggu setelah pembayaran dilakukan',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Alternative manual button for testing
                      ElevatedButton(
                        onPressed: () {
                          // This is a shortcut for demo - in production you should rely on real payment verification
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentSuccessPage(
                                orderId: orderId ?? 'test-order',
                                amount: widget.totalPayment,
                                buyerData: widget.buyerData,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Lanjutkan (Demo Mode)'),
                      ),
                      const SizedBox(height: 16),
                      // Instructions
                      _buildPaymentInstructions(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Payment method selection widgets
  Widget _buildPaymentMethodSelection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Metode Pembayaran:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          
          // QRIS Payment Option
          _buildPaymentOption(
            title: 'QRIS',
            subtitle: 'GoPay, OVO, DANA, LinkAja, dll',
            icon: Icons.qr_code,
            onTap: () => _selectPaymentMethod(PaymentMethod.qris),
          ),
          
          const SizedBox(height: 12),
          
          // Bank Transfer Options
          const Text(
            'Transfer Bank:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          
          _buildPaymentOption(
            title: 'BCA Virtual Account',
            subtitle: 'Bayar dari m-BCA atau ATM BCA',
            icon: Icons.account_balance,
            onTap: () => _selectPaymentMethod(PaymentMethod.bca),
          ),
          
          const SizedBox(height: 8),
          
          _buildPaymentOption(
            title: 'BNI Virtual Account',
            subtitle: 'Bayar dari m-Banking BNI atau ATM BNI',
            icon: Icons.account_balance,
            onTap: () => _selectPaymentMethod(PaymentMethod.bni),
          ),
          
          const SizedBox(height: 8),
          
          _buildPaymentOption(
            title: 'Mandiri Virtual Account',
            subtitle: 'Bayar dari m-Banking Mandiri atau ATM Mandiri',
            icon: Icons.account_balance,
            onTap: () => _selectPaymentMethod(PaymentMethod.mandiri),
          ),
        ],
      ),
    );
  }
  
  // Helper widget for a payment option
  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: const Color(0xFF0D1B2A)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
