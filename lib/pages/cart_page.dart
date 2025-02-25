import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_button.dart';
import '../components/my_cart_item_tile.dart';
import '../models/shop.dart';
import '../services/firestore_template.dart';

class CartPage extends StatefulWidget {
  // Use super parameter for 'key'
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Pay button was pressed
  Future<void> payNow() async {
    // 1) Access the Shop provider to get the cart items
    final shopProvider = context.read<Shop>();
    final cart = shopProvider.cart;

    // 2) Calculate total price
    double totalPrice = 0.0;
    for (final product in cart) {
      totalPrice += product.price;
    }

    // 3) Get current user (if logged in), otherwise fallback to 'guest'
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    // 4) Try to create an order in Firestore
    try {
      await FirestoreService().createOrder(
        userId: userId,
        cartItems: cart,
        totalPrice: totalPrice,
      );

      // 5) After the async call, check if we're still mounted before using context
      if (!mounted) return;

      // On success, show a success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Order Placed'),
          content: const Text('Your order has been successfully created!'),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                // Clear the cart using the clearCart() method
                shopProvider.clearCart();
              },
              color: Theme.of(context).colorScheme.secondary,
              elevation: 0,
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // 6) If there's an error, also check if we're still mounted
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Error'),
          content: Text('Failed to create order: $e'),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              color: Theme.of(context).colorScheme.secondary,
              elevation: 0,
              child: Text(
                'OK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get access to cart
    final cart = context.watch<Shop>().cart;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title heading
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 0),
                child: Text(
                  "Cart",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 32,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 25),
                child: Text(
                  "Check your cart before paying!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              // Cart list
              Expanded(
                child: cart.isEmpty
                    ? Center(
                        child: Text(
                          'Your cart is empty..',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          // Get individual product item
                          final item = cart[index];
                          // Return cart item tile
                          return MyCartItemTile(item: item);
                        },
                      ),
              ),
              // Pay button
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Row(
                  children: [
                    Expanded(
                      // Only show pay button if there are items in cart
                      child: cart.isEmpty
                          ? const SizedBox()
                          : MyButton(
                              onTap: payNow,
                              widget: Center(
                                child: Text(
                                  'P A Y   N O W',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
