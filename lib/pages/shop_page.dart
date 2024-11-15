import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../components/my_app_bar.dart';
import '../components/my_cart_button.dart';
import '../components/my_drawer.dart';
import '../components/my_product_tile.dart';
import '../models/shop.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // access products in shop
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
          // title
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 0),
            child: Text(
              "Shop",
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 32,
              ),
            ),
          ),

          // subtitle
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10, bottom: 0),
            child: Text(
              "Pick from a selected list of premium products",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),

          // product list
          SizedBox(
            height: 550,
            child: ListView.builder(
              itemCount: products.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(15),
              itemBuilder: (context, index) {
                // get each individual product from shop
                final product = products[index];

                // return as a tile
                return MyProductTile(product: product);
              },
            ),
          ),

          // bottom text
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 25.0),
            child: Center(
              child: Text(
                "m i n i m a l  x  s h o p",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
