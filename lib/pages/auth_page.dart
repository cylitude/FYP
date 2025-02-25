import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimalecom/pages/intro_page.dart';
import 'package:minimalecom/pages/shop_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listens to auth state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in, go to ShopPage
        if (snapshot.hasData) {
          return const ShopPage();
        }
        // Otherwise, show IntroPage
        else {
          return const IntroPage();
        }
      },
    );
  }
}
