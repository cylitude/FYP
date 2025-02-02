import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/shop.dart';
import 'pages/about_page.dart';
import 'pages/cart_page.dart';
import 'pages/shop_page.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart'; // Import LoginPage
import 'pages/settings_page.dart';
import 'theme/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),

        // Shop provider
        ChangeNotifierProvider(
          create: (context) => Shop(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/intro_page', // Start with the Intro Page
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/intro_page': (context) => const IntroPage(),
        '/login_page': (context) => LoginPage(),
        '/shop_page': (context) => const ShopPage(),
        '/cart_page': (context) => const CartPage(),
        '/settings_page': (context) => const SettingsPage(),
        '/about_page': (context) => const AboutPage(),
      },
    );
  }
}
