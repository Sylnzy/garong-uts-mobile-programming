import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'views/splash/splash_screen.dart';
import 'views/cart/cart_page.dart';
import 'views/home/home_page.dart';
import 'views/profile/profile_page.dart'; 

import 'firebase_options.dart'; // jika pakai FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // pastikan ini sesuai
  );
  runApp( MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garong App',
      theme: ThemeData(primarySwatch: Colors.green),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      initialRoute: '/',
      routes: {
      '/home': (context) => const HomePage(),       // misalnya homepage kamu
      '/cart': (context) => const CartPage(),   // halaman keranjang
      // '/profile': (context) => const ProfilePage(), // kalau ada halaman profil
      },
    );
  }
}
