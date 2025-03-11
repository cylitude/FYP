import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth

import '../components/my_app_bar.dart';
import '../components/my_cart_button.dart';
import '../components/my_drawer.dart';
import '../components/my_product_tile.dart';
import '../models/shop.dart';

// Import your recommender logic file
import 'recommender_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  /// We'll store the future that fetches the recommended size
  late Future<String> _recommendedSizeFuture;

  @override
  void initState() {
    super.initState();

    // 1) Grab the current Firebase user
    final user = FirebaseAuth.instance.currentUser;

    // 2) If user is logged in, get the real userId; otherwise fallback
    final userId = user?.uid ?? 'guest';

    // 3) Call your recommender logic to fetch from Firestore
    _recommendedSizeFuture = RecommenderPage().getRecommendedSizeForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    // Access products in shop
    final products = context.watch<Shop>().shop;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const MyAppBar(
        title: '',
        actions: [
          // cart button
          MyCartButton()
        ],
      ),
      drawer: const MyDrawer(),
      body: ListView(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 0),
            child: Text(
              "Shop",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
              ),
            ),
          ),
          // Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 0),
            child: Text(
              "Choose from a curated selection of our premium products",
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          // 4) Use FutureBuilder to wait for recommended size
          FutureBuilder<String>(
            future: _recommendedSizeFuture,
            builder: (context, snapshot) {
              // Show loading indicator while waiting
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 550,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // If there's an error or no data, default to 'S'
              final recommendedSize = snapshot.data ?? 'S';

              // 5) Build the horizontal product list with the recommended size
              return SizedBox(
                height: 550,
                child: ListView.builder(
                  itemCount: products.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(15),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // Pass recommendedSize to your product tile
                    return MyProductTile(
                      product: product,
                      recommendedSize: recommendedSize,
                    );
                  },
                ),
              );
            },
          ),

          // Bottom text
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 25.0),
            child: Center(
              child: Text(
                "Virtual Fashion Assistant",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
