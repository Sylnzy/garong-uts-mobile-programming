import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uts_garong_test/providers/cart_provider.dart';

class MidtransService {
  // Midtrans credentials
  static const String _baseUrl = "https://api.sandbox.midtrans.com/v2";
  static const String _serverKey = "SB-Mid-server-IaWeypq7Th1hOyXs2T-3W27b";
  static const String _clientKey = "SB-Mid-client-Xri3ekKPWn4DxrRa";
  static const String _merchantId = "G285450470";
  
  // Base64 encode the server key for authentication
  static String get _auth => 'Basic ${base64.encode(utf8.encode(_serverKey + ':'))}';

  // Generate QR Code transaction
  static Future<Map<String, dynamic>> generateQRCode({
    required String orderId,
    required int grossAmount,
    required String name,
    required String phone,
    String? email,
    String? address,
  }) async {
    final url = Uri.parse('$_baseUrl/charge');
    
    final payload = {
      'payment_type': 'qris',
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': grossAmount,
      },
      'customer_details': {
        'first_name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty)
          'billing_address': {
            'address': address,
          }
      },
      'qris': {
        'acquirer': 'gopay'
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _auth,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate QR Code: ${response.body}');
    }
  }
  
  // Generate Virtual Account transaction
  static Future<Map<String, dynamic>> generateVirtualAccount({
    required String orderId,
    required int grossAmount,
    required String name,
    required String phone,
    String? email,
    String? address,
    required String bankCode,
  }) async {
    final url = Uri.parse('$_baseUrl/charge');
    
    final payload = {
      'payment_type': 'bank_transfer',
      'transaction_details': {
        'order_id': orderId,
        'gross_amount': grossAmount,
      },
      'customer_details': {
        'first_name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (address != null && address.isNotEmpty)
          'billing_address': {
            'address': address,
          }
      },
      'bank_transfer': {
        'bank': bankCode,
      }
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _auth,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate Virtual Account: ${response.body}');
    }
  }

  // Check transaction status
  static Future<Map<String, dynamic>> checkTransactionStatus(String orderId) async {
    final url = Uri.parse('$_baseUrl/$orderId/status');
    
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': _auth,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check transaction status: ${response.body}');
    }
  }
}