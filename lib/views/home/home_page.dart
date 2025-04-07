import 'package:flutter/material.dart';
import '/core/constant/text_style.dart';
import '/data/models/product_model.dart';
import '/views/widgets/product_card.dart';
import '/views/widgets/category_item.dart';
import '/views/home/product_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/views/widgets/custom_navbar.dart';
import '/views/widgets/custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/services/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<String> _drawerItems = [
    'Home',
    'Pesanan',
    'Order History',
    'Lokasi',
    'About',
    'Setting',
    'Logout',
  ];

  late Stream<List<ProductModel>> productsStream;

  @override
  void initState() {
    super.initState();
    productsStream = FirebaseService.getProductsStream();
    print('Stream initialized in HomePage'); // Debug print
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/lokasi');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/about');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/setting');
        break;
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_drawerItems[_selectedIndex]),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      drawer: CustomDrawer(currentRoute: '/', onLogout: _logout),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Lagi cari apa nih ?',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Promo Carousel'),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kategori', style: AppTextStyle.heading),
                      Text('View All', style: AppTextStyle.link),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      CategoryItem(
                        title: 'Sembako',
                        icon: Icons.shopping_basket,
                        onTap: () {},
                      ),
                      CategoryItem(
                        title: 'Minuman',
                        icon: Icons.local_drink,
                        onTap: () {},
                      ),
                      CategoryItem(
                        title: 'Makanan',
                        icon: Icons.fastfood,
                        onTap: () {},
                      ),
                      CategoryItem(
                        title: 'Lainnya',
                        icon: Icons.category,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Rekomendasi', style: AppTextStyle.heading),
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<ProductModel>>(
                  stream: productsStream,
                  builder: (context, snapshot) {
                    print(
                      'StreamBuilder update: ${snapshot.connectionState}',
                    ); // Debug print

                    if (snapshot.hasError) {
                      print(
                        'StreamBuilder error: ${snapshot.error}',
                      ); // Debug print
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = snapshot.data ?? [];
                    print(
                      'Received ${products.length} products',
                    ); // Debug print

                    if (products.isEmpty) {
                      return const Center(child: Text('No products available'));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                          child: ProductCard(product: product),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          CustomNavBar(scaffoldKey: _scaffoldKey, currentRoute: '/'),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.shopping_cart;
      case 2:
        return Icons.history;
      case 3:
        return Icons.location_on;
      case 4:
        return Icons.info;
      case 5:
        return Icons.settings;
      case 6:
        return Icons.logout;
      default:
        return Icons.circle;
    }
  }
}
