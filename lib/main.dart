import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'models/shop.dart';
import 'theme/theme_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/auth_page.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/shop_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/gemini_page.dart';
import 'pages/orders_page.dart';
import 'pages/measurements_page.dart';
import 'pages/paymentdetails_page.dart';
import 'pages/moodboard_page.dart';
import 'pages/addressdetails_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Gemini.init(apiKey: "AIzaSyBZWMVEtxlmjU9gOplzJKI3H-W-CP7NswQ");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => Shop()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // ← super parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/auth_page',
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/auth_page':         (_) => const AuthPage(),
        '/intro_page':        (_) => const IntroPage(),
        '/login_page':        (_) => const LoginPage(),
        '/register_page':     (_) => const RegisterPage(),
        '/measurements_page': (_) => const BodyMeasurementPage(),
        '/shop_page':         (_) => const ShopPage(),
        '/cart_page':         (_) => const CartPage(),
        '/orders_page':       (_) => const OrdersPage(),
        '/profile_page':      (_) => const ProfilePage(),
        '/paymentdetails_page':(_) => const PaymentDetailsPage(),
        '/gemini_page':       (_) => const GeminiPage(),
        '/moodboard_page':    (_) => const MoodboardPage(),
        '/addressdetails_page':(_) => const AddressDetailsPage(),
      },
    );
  }
}
