import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../components/my_button.dart';
import '../components/my_cart_item_tile.dart';
import '../models/shop.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // pay button was pressed
  void payNow(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content:
            const Text("User wants to pay! Connect this app to your backend."),
        actions: [
          // cancel
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).colorScheme.secondary,
            elevation: 0,
            child: Text(
              'Ok',
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
    // get access to cart
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
              // title heading
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
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ),

              // cart list
              Expanded(
                child: cart.isEmpty
                    ? Center(
                        child: Text(
                          'Your cart is empty..',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          // get individual product item
                          final item = cart[index];

                          // return cart item tile
                          return MyCartItemTile(item: item);
                        },
                      ),
              ),

              // pay button
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Row(
                  children: [
                    Expanded(
                      // only show pay button if there are items in cart
                      child: cart.isEmpty
                          ? const SizedBox()
                          : MyButton(
                              onTap: () => payNow(context),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
