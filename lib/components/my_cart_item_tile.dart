import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop.dart'; // For CartItem, Shop

class MyCartItemTile extends StatelessWidget {
  final CartItem item; // A CartItem that includes product, size, quantity

  const MyCartItemTile({
    super.key,
    required this.item,
  });

  /// Confirm removal of this item from cart
  void removeItemFromCart(BuildContext context) {
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
          // yes => remove
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
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
    final shop = context.read<Shop>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Product image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.secondary,
            ),
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                product.imagePath,
                height: 64,
              ),
            ),
          ),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                // Product price
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 12,
                  ),
                ),
                // Chosen size
                Text(
                  'Size: ${item.size}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Column(
            children: [
              // Plus (+) button
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  shop.increaseQuantity(item);
                },
              ),
              // Quantity display
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Minus (–) button
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  shop.decreaseQuantity(item);
                },
              ),
            ],
          ),
          // Remove item from cart (X)
          IconButton(
            iconSize: 20,
            onPressed: () => removeItemFromCart(context),
            icon: const Icon(
              Icons.highlight_remove,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
