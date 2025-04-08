import 'package:flutter/material.dart';
import '../views/splash/splash_screen.dart';
import '../views/cart/cart_page.dart';
import '../views/home/home_page.dart';
import '../views/profile/profile_page.dart';
import '../views/auth/login_page.dart';
import '../views/profile/edit_profile_page.dart';
import '../views/pages/order_history_page.dart';
import '../views/pages/lokasi_page.dart';
import '../views/pages/about_page.dart';
import '../views/pages/setting_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/': (context) => const HomePage(),
    '/cart': (context) => const CartPage(),
    '/profile': (context) => const ProfilePage(),
    '/edit-profile': (context) => const EditProfilePage(),
    '/history': (context) => const OrderHistoryPage(),
    '/location': (context) => const LokasiPage(),
    '/about': (context) => const AboutPage(),
    '/setting': (context) => const SettingPage(),
  };
}
