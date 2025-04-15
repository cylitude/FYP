import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart';
import '../components/my_product_tile.dart';

class PopupPage extends StatelessWidget {
  const PopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the shop model and retrieve the Oxford Black Shirt
    final shop = context.watch<Shop>();
    final oxfordBlackShirt = shop.shop.firstWhere(
      (product) => product.name == "Oxford Black Shirt",
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        // Center the content both vertically and horizontally
        child: Center(
          // Limit content width to 3/4 of the screen
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              children: [
                // Title text at the top
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "VAVA recommends...",
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple, // Title now in purple
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Display the product tile for Oxford Black Shirt
                Expanded(
                  child: Center(
                    child: MyProductTile(
                      product: oxfordBlackShirt,
                      recommendedSize: 'XL', // Adjust as needed
                    ),
                  ),
                ),
                // "EXIT" button at the bottom styled like in profile_page.dart
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/shop_page');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text(
                      "EXIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
