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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  String _searchQuery = "";
  String _selectedCategory = "All";
  late Stream<List<ProductModel>> productsStream;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    productsStream = FirebaseService.instance.getProductsStream();
    _startAutoSlide();
    _animationController.forward();
    debugPrint('Stream initialized in HomePage');

    // Initialize onboarding guide with a slight delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initOnboardingGuide();
    });
  }

  Future<void> _initOnboardingGuide() async {
    final bool isNewUser = await OnboardingService.hasSeenOnboarding() == false;
    if (isNewUser && mounted) {
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
        contentPositions: [
          ContentPosition.bottom,
          ContentPosition.bottom,
          ContentPosition.bottom,
          ContentPosition.bottom,
          ContentPosition.bottom,
        ],
      );
      guide.showGuide();
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _animationController.dispose();
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
        "color": "#4E8FDE", // Custom color for this banner
      },
      {
        "title": "Gratis Ongkir",
        "desc": "Gunakan kode GRATONG dan dapatkan gratis ongkir!",
        "image": "assets/images/gratong.png", // Gambar lokal
        "color": "#FE7A36", // Custom color for this banner
      },
      {
        "title": "Voucher Belanja",
        "desc": "Gunakan kode WARUNGHEMAT untuk potongan 10%",
        "image": "assets/images/diskon.png", // Gambar lokal
        "color": "#3AA346", // Custom color for this banner
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
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _animationController.reset();
      _animationController.forward();
    });
  }

  // Helper function to parse color from hex string
  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null) return const Color(0xFF778DA9);
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
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
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Container with search bar and banner
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D1B2A), Color(0xFF1A2C42)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Greeting and Welcome Text
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            StreamBuilder<User?>(
                              stream: FirebaseAuth.instance.authStateChanges(),
                              builder: (context, snapshot) {
                                final user = snapshot.data;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, ${user?.displayName?.split(' ').first ?? 'Pengguna'}! 👋',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Mau belanja apa hari ini?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons
                                    .help_outline, // Changed from notifications_outlined to help_outline
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                // Reset onboarding status
                                await OnboardingService.resetOnboarding();

                                // Show the guide directly
                                if (mounted) {
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
                                    contentPositions: [
                                      ContentPosition.bottom,
                                      ContentPosition.bottom,
                                      ContentPosition.bottom,
                                      ContentPosition.bottom,
                                      ContentPosition.bottom, 
                                    ],
                                  );
                                  guide.showGuide();
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // Search Bar with enhanced styling
                      Container(
                        key: _searchKey, // Add key for targeting
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                              _animationController.reset();
                              _animationController.forward();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Lagi cari apa nih?",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF0D1B2A),
                            ),
                            suffixIcon:
                                _searchQuery.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Color(0xFF0D1B2A),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = "";
                                        });
                                      },
                                    )
                                    : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Banner Carousel with enhanced design
                      SizedBox(
                        key: _bannerKey, // Add key for targeting
                        height: 175,
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
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    _getColorFromHex(banner["color"]),
                                    _getColorFromHex(
                                      banner["color"],
                                    ).withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getColorFromHex(
                                      banner["color"],
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            banner["title"]!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 2.0,
                                                  color: Colors.black26,
                                                  offset: Offset(1.0, 1.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            banner["desc"]!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Lihat Promo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: _getColorFromHex(
                                                  banner["color"],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Hero(
                                      tag: 'banner-${banner["title"]}',
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
                                  const SizedBox(width: 10),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Enhanced Banner indicators
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _getBannerItems().length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentBannerIndex == index ? 18 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  _currentBannerIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                              boxShadow:
                                  _currentBannerIndex == index
                                      ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ]
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories and Products section with enhanced styling
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category title with enhanced styling
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 12),
                        child: Row(
                          key: _categoriesKey, // Add key for targeting
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D1B2A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kategori',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D1B2A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Enhanced Category grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
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
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF0D1B2A),
                                            Color(0xFF1A2C42),
                                          ],
                                        )
                                        : null,
                                color: isSelected ? null : Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0D1B2A,
                                            ).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                        : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Colors.white.withOpacity(0.2)
                                                : const Color(
                                                  0xFF0D1B2A,
                                                ).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category["icon"],
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF0D1B2A),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        category["name"],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF0D1B2A),
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

                      const SizedBox(height: 24),

                      // Products section with enhanced styling
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          key: _productsKey, // Add key for targeting
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D1B2A),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rekomendasi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0D1B2A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1A7AFF),
                              ),
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Products grid with enhanced styling and animations
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
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        productsStream =
                                            FirebaseService.instance
                                                .getProductsStream();
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D1B2A),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
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

                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: _animationController,
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
                                        MaterialPageRoute(
                                          builder:
                                              (context) => ProductDetailPage(
                                                product: product,
                                              ),
                                        ),
                                      );
                                    },
                                    child: ProductCard(product: product),
                                  );
                                },
                              ),
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
    // A grid of gray placeholder cards with shimmer effect
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
          elevation: 2,
          color: const Color.fromARGB(255, 145, 159, 180),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(height: 120, color: Colors.grey[300]),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: const Color.fromARGB(255, 26, 0, 0),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Container(width: 100, height: 24, color: Colors.grey[300]),
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
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.category_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Produk "$_searchQuery" tidak ditemukan'
                  : 'Tidak ada produk di kategori ini',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba dengan kata kunci lain'
                  : 'Silakan pilih kategori lain',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
