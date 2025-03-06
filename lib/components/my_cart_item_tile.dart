import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart'; // For CartItem, Shop

class MyCartItemTile extends StatelessWidget {
  final CartItem item; // instead of Product, we accept a CartItem

  const MyCartItemTile({
    super.key,
    required this.item,
  });

  // remove this item from cart
  void removeItemFromCart(BuildContext context) {
    // show dialog to confirm removal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: const Text("Are you sure you want to remove this item?"),
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
              // remove from cart (pass the entire CartItem)
              context.read<Shop>().removeFromCart(item);
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
    // For convenience, reference the product inside the cart item
    final product = item.product;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // product image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    product.imagePath,
                    height: 64,
                  ),
                ),
              ),
              // product info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // product price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 12,
                    ),
                  ),
                  // chosen size
                  Text(
                    'Size: ${item.size}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Remove from cart button: smaller container and icon
          Container(
            width: 40,
            height: 40,
            // Optionally add a border or background if needed:
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              iconSize: 20,
              onPressed: () => removeItemFromCart(context),
              icon: const Icon(
                Icons.highlight_remove,
                color: Colors.black, // trolley icon now black
              ),
            ),
          ),
        ],
      ),
    );
  }
}
