import 'package:flutter/material.dart';
import 'dart:async';
import '/core/constant/text_style.dart';
import '/data/models/product_model.dart';
import '/views/widgets/product_card.dart';
import '/views/home/product_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/views/widgets/custom_navbar.dart';
import '/views/widgets/custom_drawer.dart';
import '/core/services/firebase_service.dart';
import '/views/widgets/feature_guide.dart';
import '/core/services/onboarding_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String _searchQuery = "";
  String _selectedCategory = "All";
  late Stream<List<ProductModel>> productsStream;

  final List<String> _drawerItems = [
    'Home',
    'Pesanan',
    'Order History',
    'Lokasi',
    'About',
    'Setting',
    'Logout',
  ];

  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.grid_view},
    {"name": "Sembako", "icon": Icons.shopping_basket},
    {"name": "Minuman", "icon": Icons.local_drink},
    {"name": "Makanan", "icon": Icons.fastfood},
  ];

  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  // Add these keys for feature targeting
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final GlobalKey _navbarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    productsStream = FirebaseService.instance.getProductsStream();
    _startAutoSlide();
    debugPrint('Stream initialized in HomePage');

    // Initialize onboarding guide with a slight delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOnboardingGuide();
    });
  }

  Future<void> _initOnboardingGuide() async {
    final bool isNewUser = await OnboardingService.hasSeenOnboarding() == false;
    if (isNewUser) {
      final guide = FeatureGuide(
        context: context,
        keys: [
          _searchKey,
          _categoriesKey,
          _bannerKey,
          _productsKey,
          _navbarKey,
        ],
        titles: [
          'Pencarian Produk',
          'Kategori Produk',
          'Promo & Informasi',
          'Katalog Produk',
          'Navigasi Utama',
        ],
        descriptions: [
          'Cari produk yang kamu inginkan dengan mudah di sini',
          'Pilih kategori untuk mencari produk sesuai kebutuhan',
          'Dapatkan informasi terbaru tentang promo dan penawaran menarik',
          'Lihat semua produk tersedia dari warung kami',
          'Akses seluruh fitur aplikasi Warung Garong dari sini',
        ],
      );
      guide.showGuide();
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex =
            (_currentBannerIndex + 1) % _getBannerItems().length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Map<String, String>> _getBannerItems() {
    return [
      {
        "title": "Warung Favorit di Genggamanmu !",
        "desc": "Beli kebutuhan sehari-hari tanpa ribet, langsung dari HP-mu.",
        "image": "assets/images/grocery.png", // Gambar lokal
      },
      {
        "title": "Gratis Ongkir",
        "desc": "Gunakan kode GRATONG dan dapatkan gratis ongkir!",
        "image": "assets/images/gratong.png", // Gambar lokal
      },
      {
        "title": "Voucher Belanja",
        "desc": "Gunakan kode WARUNGHEMAT untuk potongan 10%",
        "image": "assets/images/diskon.png", // Gambar lokal
      },
    ];
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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: CustomDrawer(currentRoute: '/', onLogout: _logout),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container with search bar and banner
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        key: _searchKey, // Add key for targeting
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E1DD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "Lagi cari apa nih?",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Banner Carousel
                      SizedBox(
                        key: _bannerKey, // Add key for targeting
                        height: 150,
                        child: PageView.builder(
                          controller: _bannerController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentBannerIndex = index;
                            });
                          },
                          itemCount: _getBannerItems().length,
                          itemBuilder: (context, index) {
                            final banner = _getBannerItems()[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF778DA9,
                                ), // Warna latar belakang default
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            banner["title"]!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            banner["desc"]!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Image.asset(
                                        banner["image"]!, // Gunakan path gambar dari data
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 80,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Banner indicators
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _getBannerItems().length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _currentBannerIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories and Products section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category title
                      Row(
                        key: _categoriesKey, // Add key for targeting
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kategori', style: AppTextStyle.heading),
                        ],
                      ),
                      const SizedBox(height: 1),

                      // Category grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.3,
                            ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              _selectedCategory == category["name"];

                          return GestureDetector(
                            onTap: () => _onCategorySelected(category["name"]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(0xFF778DA9)
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(
                                      category["icon"],
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        category["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Products section
                      Row(
                        key: _productsKey, // Add key for targeting
                        children: [
                          Text('Rekomendasi', style: AppTextStyle.heading),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Products grid with search and category filtering
                      StreamBuilder<List<ProductModel>>(
                        stream: productsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildProductsPlaceholder();
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Something went wrong: ${snapshot.error}',
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        productsStream =
                                            FirebaseService.instance
                                                .getProductsStream();
                                      });
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<ProductModel> products = snapshot.data ?? [];

                          // Filter products by search query
                          if (_searchQuery.isNotEmpty) {
                            products =
                                products
                                    .where(
                                      (product) => product.name
                                          .toLowerCase()
                                          .contains(_searchQuery),
                                    )
                                    .toList();
                          }

                          // Filter products by selected category
                          if (_selectedCategory != "All") {
                            products =
                                products
                                    .where(
                                      (product) =>
                                          product.category == _selectedCategory,
                                    )
                                    .toList();
                          }

                          if (products.isEmpty) {
                            return _buildEmptyProductsView();
                          }

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: GridView.builder(
                              key: ValueKey<String>(
                                '$_selectedCategory-$_searchQuery',
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        pageBuilder:
                                            (_, animation, __) =>
                                                ProductDetailPage(
                                                  product: product,
                                                ),
                                        transitionsBuilder: (
                                          _,
                                          animation,
                                          __,
                                          child,
                                        ) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOut,
                                              ),
                                            ),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: 'product-${product.id}',
                                    child: AnimatedProductCard(
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Bottom padding for navbar
                const SizedBox(height: 80),
              ],
            ),
          ),
          CustomNavBar(
            key: _navbarKey, // Add key for targeting
            scaffoldKey: _scaffoldKey,
            currentRoute: '/',
          ),
        ],
      ),
    );
  }

  Widget _buildProductsPlaceholder() {
    // A grid of gray placeholder cards
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4, // Show 4 placeholders
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Container(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 16, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyProductsView() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No products matching "$_searchQuery"'
                  : 'No products in this category',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedProductCard extends StatefulWidget {
  final ProductModel product;

  const AnimatedProductCard({super.key, required this.product});

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isHovered ? 6 : 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child:
                    widget.product.imageUrl.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                          ),
                        )
                        : const Icon(
                          Icons.shopping_basket,
                          size: 60,
                          color: Colors.grey,
                        ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      widget.product.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${widget.product.price.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
