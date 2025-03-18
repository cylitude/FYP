import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // <-- Import for Gemini.init

// Models
import 'models/shop.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'pages/auth_page.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/shop_page.dart';
import 'pages/cart_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/gemini_page.dart';
import 'pages/orders_page.dart';
import 'pages/measurements_page.dart';
import 'pages/paymentdetails_page.dart'; 

// Theme
import 'theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Gemini once here in main(), rather than inside gemini_page.dart
  Gemini.init(apiKey: "AIzaSyBZWMVEtxlmjU9gOplzJKI3H-W-CP7NswQ");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => Shop()),
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
      // Start with AuthPage, which decides whether to show ShopPage or IntroPage
      initialRoute: '/auth_page',
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/auth_page': (context) => const AuthPage(),
        '/intro_page': (context) => const IntroPage(),
        '/login_page': (context) => const LoginPage(),
        '/register_page': (context) => const RegisterPage(),
        '/measurements_page': (context) => const BodyMeasurementPage(),
        '/shop_page': (context) => const ShopPage(),
        '/cart_page': (context) => const CartPage(),
        '/orders_page': (context) => const OrdersPage(),
        '/settings_page': (context) => const SettingsPage(),
        '/profile_page': (context) => const ProfilePage(),
        '/paymentdetails_page': (context) => const PaymentDetailsPage(),
        '/gemini_page': (context) => const GeminiPage(),
      },
    );
  }
}
