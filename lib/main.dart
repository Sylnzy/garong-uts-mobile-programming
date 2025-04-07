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
import 'firebase_options.dart';
// import 'core/services/firebase_seeder.dart';

Future<void> setupFirebase() async {
  try {
    // Initialize Firebase if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    // Force set the database URL regardless of what's in firebase_options.dart
    FirebaseDatabase.instance.databaseURL = 'https://garong-app-default-rtdb.asia-southeast1.firebasedatabase.app';
    
    // Debug info
    debugPrint('Firebase Apps Count: ${Firebase.apps.length}');
    debugPrint('Database URL: ${FirebaseDatabase.instance.databaseURL}');
    debugPrint('Project ID: ${Firebase.apps.first.options.projectId}');
    
    // Test database connection
    final connectionRef = FirebaseDatabase.instance.ref(".info/connected");
    final event = await connectionRef.once();
    final isConnected = event.snapshot.value as bool? ?? false;
    debugPrint('Connected to Realtime Database: $isConnected');
    
    return;
  } catch (e, stack) {
    debugPrint('Firebase setup error: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Set up Firebase with correct configuration
    await setupFirebase();
    
    // Continue with your app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Error in main: $e');
    // Still run the app even if Firebase setup fails
    runApp(const MyApp());
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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/cart': (context) => const CartPage(),
        '/profile': (context) => const ProfilePage(),
        '/edit-profile': (context) => const EditProfilePage(),
        '/history': (context) => const OrderHistoryPage(),
        '/lokasi': (context) => const LokasiPage(),
        '/about': (context) => const AboutPage(),
        '/setting': (context) => const SettingPage(),
      },
    );
  }
}
