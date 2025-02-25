import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/shop.dart';
import 'pages/auth_page.dart';
import 'pages/intro_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/shop_page.dart';
import 'pages/cart_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/chatbot_page.dart';
import 'pages/analytics_page.dart';
import 'pages/orders_page.dart'; 
import 'theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        '/shop_page': (context) => const ShopPage(),
        '/cart_page': (context) => const CartPage(),
        '/orders_page': (context) => const OrdersPage(), 
        '/settings_page': (context) => const SettingsPage(),
        '/about_page': (context) => const AboutPage(),
        '/chatbot_page': (context) => ChatbotPage(),
        '/analytics_page': (context) => AnalyticsPage(),
      },
    );
  }
}
