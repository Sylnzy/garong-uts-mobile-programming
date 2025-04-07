import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'providers/cart_provider.dart';
import 'views/splash/splash_screen.dart';
import 'views/cart/cart_page.dart';
import 'views/home/home_page.dart';
import 'views/profile/profile_page.dart';
import 'views/auth/login_page.dart';
import 'views/profile/edit_profile_page.dart';
import 'views/pages/order_history_page.dart';
import 'views/pages/lokasi_page.dart';
import 'views/pages/about_page.dart';
import 'views/pages/setting_page.dart';
import 'utils/firebase_seeder.dart';

import 'firebase_options.dart'; // jika pakai FlutterFire CLI
import 'core/services/firebase_service.dart';

Future<void> initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure Realtime Database
    FirebaseDatabase.instance.databaseURL =
        'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app';
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase only if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize FirebaseService after Firebase is initialized
      await FirebaseService.initialize();
    }

    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garong App',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Changed this
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomePage(), // Home as root route
        '/login': (context) => LoginPage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/history': (context) => const OrderHistoryPage(),
        '/lokasi': (context) => const LokasiPage(),
        '/about': (context) => const AboutPage(),
        '/setting': (context) => const SettingPage(),
        // ...other routes...
      },
    );
  }
}
