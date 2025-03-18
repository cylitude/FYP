import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../components/my_app_bar.dart';
import '../components/my_cart_button.dart';
import '../components/my_drawer.dart';
import '../components/my_product_tile.dart';
import '../models/shop.dart';
import 'recommender_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late Future<String> _recommendedSizeFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    _recommendedSizeFuture = RecommenderPage().getRecommendedSizeForUser(userId);
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<Shop>().shop;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const MyAppBar(
        title: '',
        actions: [
          MyCartButton()
        ],
      ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 0),
                child: Text(
                  "Hello There, Welcome",
                  style: GoogleFonts.dmSerifDisplay(fontSize: 28),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 0),
                child: Text(
                  "Dress to Impress: Premium Shirts for Every Occasion",
                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),
              FutureBuilder<String>(
                future: _recommendedSizeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 550,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final recommendedSize = snapshot.data ?? 'S';
                  return SizedBox(
                    height: 550,
                    child: ListView.builder(
                      itemCount: products.length,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return MyProductTile(
                          product: product,
                          recommendedSize: recommendedSize,
                        );
                      },
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 25.0),
                child: Center(
                  child: Text(
                    "The Shirt Boutique",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Promotional banner
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Text(
                "INSERT SUMMERVIBES20 FOR 20% OFF CART",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold 
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
