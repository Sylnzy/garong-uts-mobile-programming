import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  final Function() onLogout;

  const CustomDrawer({
    Key? key,
    required this.currentRoute,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get current user data
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0D1B2A)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                  child:
                      user?.photoURL == null
                          ? const Icon(
                            Icons.person,
                            size: 35,
                            color: Color(0xFF0D1B2A),
                          )
                          : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hello, ${user?.displayName ?? 'User'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  title: 'Home',
                  icon: Icons.home,
                  route: '/',
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Pesanan',
                  icon: Icons.shopping_cart,
                  route: '/cart',
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Order History',
                  icon: Icons.history,
                  route: '/history',
                ),
                
                _buildDrawerItem(
                  context: context,
                  title: 'About',
                  icon: Icons.info_outline,
                  route: '/about',
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Setting',
                  icon: Icons.settings,
                  route: '/setting',
                ),
                _buildDrawerItem(
                  context: context,
                  title: 'Profile',
                  icon: Icons.person,
                  route: '/profile',
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
  }) {
    final bool isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0D1B2A) : null),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0D1B2A) : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
