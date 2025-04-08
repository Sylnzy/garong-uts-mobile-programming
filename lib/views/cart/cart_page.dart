import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:uts_garong_test/views/payment/data_pembeli_page.dart';
import '/views/widgets/custom_navbar.dart';
import '/views/widgets/custom_drawer.dart';
import '/data/models/product_model.dart';
import 'package:firebase_database/firebase_database.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  double _discount = 0.0;
  String _usedCoupon = '';
  bool isDelivery = true; // Delivery selection state
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> productImages = {};

  @override
  void initState() {
    super.initState();
    _loadProductImages();
  }

  Future<void> _loadProductImages() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productIds = cart.items.keys.toList();

    if (productIds.isEmpty) return;

    try {
      final dbRef = FirebaseDatabase.instance.ref().child('products');

      for (String productId in productIds) {
        final snapshot = await dbRef.child(productId).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            productImages[productId] = data['imageUrl'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading product images: $e');
    }
  }

  void _logout() {
    // Add your logout logic here
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void applyCoupon(String code) {
    Map<String, double> coupons = {
      'warunghemat': 0.10,
      'gratong': 0.0, // Special code for free delivery
      'maul': 0.05,
      'naila': 0.02,
      'amel': 0.10,
    };

    setState(() {
      _discount = coupons[code.toLowerCase()] ?? 0.0;
      _usedCoupon = code;
    });

    if (_discount > 0 || code.toLowerCase() == 'gratong') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kupon "$code" berhasil digunakan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kupon tidak valid.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();

    // Calculate delivery fee (free if GRATONG coupon is used)
    final deliveryFee =
        isDelivery ? (_usedCoupon.toLowerCase() == 'gratong' ? 0 : 20000) : 0;

    final subtotal = cart.totalAmount;
    final discountAmount = (subtotal * _discount).toInt();
    final total = subtotal - discountAmount + deliveryFee;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false, // Add this line
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: CustomDrawer(currentRoute: '/cart', onLogout: _logout),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Delivery/Pickup selection
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pengambilan:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text(
                                  'Delivery',
                                  style: TextStyle(fontSize: 15.5),
                                ),
                                value: true,
                                groupValue: isDelivery,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isDelivery = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text(
                                  'Self Pickup',
                                  style: TextStyle(fontSize: 15.5),
                                ),
                                value: false,
                                groupValue: isDelivery,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isDelivery = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Product list
                  Expanded(
                    child:
                        items.isEmpty
                            ? const Center(child: Text('Keranjang kosong'))
                            : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (ctx, i) {
                                final item = items[i];
                                final productId = cart.items.keys.elementAt(i);
                                final imageUrl = productImages[productId] ?? '';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEFEF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      // Product image with correct URL
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            imageUrl.isNotEmpty
                                                ? Image.network(
                                                  imageUrl,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    );
                                                  },
                                                )
                                                : Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Product details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              currencyFormatter.format(
                                                item.price,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Quantity controls
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                // Use decreaseQuantity method
                                                cart.decreaseQuantity(
                                                  productId,
                                                );
                                              } else {
                                                cart.removeItem(productId);
                                              }
                                            },
                                          ),
                                          Text('${item.quantity}'),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              // Call addItem with productId
                                              cart.addItem(
                                                productId,
                                                item.title,
                                                item.price,
                                                1,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),

                  // Coupon section
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          decoration: InputDecoration(
                            hintText: 'Kupon Diskon',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => applyCoupon(_couponController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1B2A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Gunakan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  // Price summary
                  const SizedBox(height: 20),
                  buildPriceRow("Sub total", subtotal),
                  if (_discount > 0)
                    buildPriceRow(
                      "Diskon (${(_discount * 100).toInt()}%)",
                      -discountAmount,
                    ),
                  buildPriceRow("Pengantaran", deliveryFee),
                  const Divider(),
                  buildPriceRow("Total", total, isBold: true),

                  // Order button
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          items.isEmpty
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DataPembeliPage(
                                          totalPayment: total,
                                          items: cart.items.values.toList(),
                                          isDelivery: isDelivery,
                                        ),
                                  ),
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Pesan Sekarang",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom navigation bar
          CustomNavBar(scaffoldKey: _scaffoldKey, currentRoute: '/cart'),
        ],
      ),
    );
  }

  Widget buildPriceRow(String label, int amount, {bool isBold = false}) {
    final isDiscount = amount < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            currencyFormatter.format(isDiscount ? -amount : amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
