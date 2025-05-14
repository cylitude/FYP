import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../components/my_product_tile.dart';

class PopupPage extends StatelessWidget {
  final Product product;                     
  const PopupPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              children: [
                // — Title —
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "VAVA recommends...",
                    style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // — The recommended product tile —
                Expanded(
                  child: Center(
                    child: MyProductTile(
                      product: product,
                      recommendedSize: 'XL',  
                    ),
                  ),
                ),

                // — EXIT button —
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: const Text(
                      "EXIT",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
