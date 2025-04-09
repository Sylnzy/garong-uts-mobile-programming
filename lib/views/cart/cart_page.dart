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
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Kupon "$code" berhasil digunakan!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              const Text('Kupon tidak valid.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items.values.toList();
    final deliveryFee =
        isDelivery ? (_usedCoupon.toLowerCase() == 'gratong' ? 0 : 20000) : 0;
    final subtotal = cart.totalAmount;
    final discountAmount = (subtotal * _discount).toInt();
    final total = subtotal - discountAmount + deliveryFee;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F1C2E),
        elevation: 0,
      ),
      drawer: CustomDrawer(currentRoute: '/cart', onLogout: _logout),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  // Compact Delivery/Pickup selection
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                          color: Color(0xFF0F1C2E),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pengiriman:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        _buildCompactDeliveryOption(
                          title: 'Delivery',
                          isSelected: isDelivery,
                          onTap: () => setState(() => isDelivery = true),
                        ),
                        const SizedBox(width: 8),
                        _buildCompactDeliveryOption(
                          title: 'Self Pickup',
                          isSelected: !isDelivery,
                          onTap: () => setState(() => isDelivery = false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Compact Coupon Row
                  if (items.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.discount_outlined,
                            size: 18,
                            color: Color(0xFF0F1C2E),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                hintText: 'Masukkan kode kupon',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[400],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                () => applyCoupon(_couponController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F1C2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(10, 34),
                            ),
                            child: const Text(
                              'Pakai',
                              style: TextStyle(fontSize: 13, color: Colors.white),
                              
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Used Coupon Indicator
                  if (_usedCoupon.isNotEmpty && items.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _usedCoupon.toLowerCase() == 'gratong'
                                ? 'Gratis ongkir diterapkan'
                                : 'Diskon ${(_discount * 100).toInt()}% diterapkan',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Product List - Increased space
                  Expanded(
                    child:
                        items.isEmpty
                            ? _buildEmptyCartView()
                            : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (ctx, i) {
                                final item = items[i];
                                final productId = cart.items.keys.elementAt(i);
                                final imageUrl = productImages[productId] ?? '';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        // Product image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              imageUrl.isNotEmpty
                                                  ? Image.network(
                                                    imageUrl,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return _buildPlaceholderImage();
                                                    },
                                                  )
                                                  : _buildPlaceholderImage(),
                                        ),
                                        const SizedBox(width: 12),

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
                                                  fontSize: 15,
                                                  color: Color(0xFF0F1C2E),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currencyFormatter.format(
                                                  item.price,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1A7AFF),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),

                                              // Quantity controls - simplified
                                              Row(
                                                children: [
                                                  _buildCompactQuantityButton(
                                                    icon: Icons.remove,
                                                    onPressed: () {
                                                      if (item.quantity > 1) {
                                                        cart.decreaseQuantity(
                                                          productId,
                                                        );
                                                      } else {
                                                        cart.removeItem(
                                                          productId,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  _buildCompactQuantityButton(
                                                    icon: Icons.add,
                                                    onPressed: () {
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
                                        ),

                                        // Delete item button
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed:
                                              () => cart.removeItem(productId),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),

                  // Compact Order Summary
                  if (items.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildCompactPriceRow("Subtotal", subtotal),
                          if (_discount > 0)
                            _buildCompactPriceRow(
                              "Diskon (${(_discount * 100).toInt()}%)",
                              -discountAmount,
                            ),
                          _buildCompactPriceRow(
                            isDelivery ? "Ongkir" : "Pengemasan",
                            deliveryFee,
                          ),
                          const Divider(height: 12, thickness: 1),
                          _buildCompactPriceRow("Total", total, isBold: true),

                          const SizedBox(height: 12),

                          // Order button
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
                                                  items:
                                                      cart.items.values
                                                          .toList(),
                                                  isDelivery: isDelivery,
                                                ),
                                          ),
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F1C2E),
                                disabledBackgroundColor: Colors.grey[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                "Pesan Sekarang",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          CustomNavBar(scaffoldKey: _scaffoldKey, currentRoute: '/cart'),
        ],
      ),
    );
  }

  // Simplified helper methods

  Widget _buildCompactDeliveryOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F1C2E) : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: const Color(0xFF0F1C2E), size: 16),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: Icon(Icons.image_outlined, color: Colors.grey[500], size: 24),
    );
  }

  Widget _buildCompactPriceRow(
    String label,
    int amount, {
    bool isBold = false,
  }) {
    final isDiscount = amount < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.grey[700],
              fontSize: isBold ? 15 : 13,
            ),
          ),
          Text(
            currencyFormatter.format(isDiscount ? -amount : amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color:
                  isDiscount
                      ? Colors.green
                      : (isBold ? const Color(0xFF0F1C2E) : Colors.grey[800]),
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  // Keep the existing _buildEmptyCartView method
  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_cart.png',
            width: 120,
            height: 120,
            // If you don't have this image, replace with:
            // Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Colors.grey[300],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Keranjang Belanja Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1C2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ayo mulai belanja untuk memenuhi\nkebutuhan anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Mulai Belanja'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F1C2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
