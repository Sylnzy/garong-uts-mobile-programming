import 'package:flutter/material.dart';
import '/core/utils/page_transition.dart';
import '/views/home/home_page.dart';
import '/views/cart/cart_page.dart';
import '/views/profile/profile_page.dart';

class CustomNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String currentRoute;

  const CustomNavBar({
    Key? key,
    required this.scaffoldKey,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          // Ukuran navbar lebih compact
          margin: const EdgeInsets.symmetric(
            horizontal: 36,
          ), // Lebih kecil dari sebelumnya
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Lebih kecil
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.menu,
                isActive: false,
                onPressed: () => scaffoldKey.currentState?.openDrawer(),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.home,
                isActive: currentRoute == '/',
                onPressed: () {
                  if (currentRoute != '/') {
                    SlideDirection direction;
                    if (currentRoute == '/cart' || currentRoute == '/profile') {
                      direction = SlideDirection.left;
                    } else {
                      direction = SlideDirection.right;
                    }

                    Navigator.pushReplacement(
                      context,
                      SlidePageRoute(
                        page: const HomePage(),
                        direction: direction,
                      ),
                    );
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.shopping_cart,
                isActive: currentRoute == '/cart',
                onPressed: () {
                  if (currentRoute != '/cart') {
                    SlideDirection direction;
                    if (currentRoute == '/') {
                      direction = SlideDirection.right;
                    } else if (currentRoute == '/profile') {
                      direction = SlideDirection.left;
                    } else {
                      direction = SlideDirection.right;
                    }

                    Navigator.pushReplacement(
                      context,
                      SlidePageRoute(
                        page: const CartPage(),
                        direction: direction,
                      ),
                    );
                  }
                },
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person,
                isActive: currentRoute == '/profile',
                onPressed: () {
                  if (currentRoute != '/profile') {
                    Navigator.pushReplacement(
                      context,
                      SlidePageRoute(
                        page: const ProfilePage(),
                        direction: SlideDirection.right,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method untuk membuat ikon navbar dengan efek mengambang bulat
  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final double iconSize = 24; // Ukuran ikon lebih kecil

    final Color activeColor = const Color(0xFF0F1C2E);
    final Color inactiveColor = Colors.grey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // Efek mengambang dengan bentuk lingkaran
      padding: const EdgeInsets.all(1), // Padding lebih kecil
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50), // Bulat sempurna
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle, // Bentuk bulat
              color: isActive ? Colors.white : Colors.transparent,
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }
}
