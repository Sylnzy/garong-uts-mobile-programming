import 'package:flutter/material.dart';
import '/core/constant/text_style.dart';
import '/data/models/product_model.dart';
import '/views/widgets/product_card.dart';
import '/views/widgets/category_item.dart';
import '/views/home/product_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Konten utama
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 60),

                // Search bar
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

                // Promo carousel placeholder
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

                // Kategori section
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

                // Kategori grid
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

                // Produk section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Rekomendasi', style: AppTextStyle.heading),
                ),
                const SizedBox(height: 10),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: dummyProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final product = dummyProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: ProductCard(product: product),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Navbar ngambang
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.menu),
                    Icon(Icons.home),
                    Icon(Icons.shopping_cart),
                    Icon(Icons.person),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
