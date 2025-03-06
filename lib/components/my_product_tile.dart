import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/shop.dart';

class MyProductTile extends StatelessWidget {
  final Product product;

  const MyProductTile({super.key, required this.product});

  // add to cart
  void addToCart(BuildContext context) {
    // show dialog box to confirm if user wants to add
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content:
            const Text("Are you sure you want to add this item to the cart?"),
        actions: [
          // cancel
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          // yes
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              // add to cart
              context.read<Shop>().addToCart(product);
            },
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            child: Text(
              'Yes',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      width: 300,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // product image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // product name
              Text(
                product.name,
                style: GoogleFonts.bebasNeue(fontSize: 36),
              ),

              // product description
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // product price
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              // add to cart button with updated icon properties
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  iconSize: 30, // slightly bigger icon size
                  onPressed: () => addToCart(context),
                  // Updated icon: shopping cart in grey
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
