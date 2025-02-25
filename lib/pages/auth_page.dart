import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minimalecom/pages/intro_page.dart';
import 'package:minimalecom/pages/shop_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged in
        if (snapshot.hasData) {
          return const ShopPage();
        }

        // User is NOT logged in
        return const IntroPage();
      },
    );
  }
}

