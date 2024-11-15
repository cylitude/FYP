import 'package:flutter/material.dart';
import 'product.dart';

class Shop extends ChangeNotifier {
  // products for sale
  final List<Product> _shop = [
    // product 1
    Product(
      name: "Product 1",
      price: 99.99,
      description: "Item description..",
      imagePath: 'assets/watch.png',
    ),

    // product 2
    Product(
      name: "Product 2",
      price: 99.99,
      description: "Item description..",
      imagePath: 'assets/shoes.png',
    ),

    // product 3
    Product(
      name: "Product 3",
      price: 99.99,
      description: "A modern, sleek & minimal pair of glasses.",
      imagePath: 'assets/glasses.png',
    ),

    // product 4
    Product(
      name: "Product 4",
      price: 99.99,
      description:
          "This is a premium black hoodie made with quality materials.",
      imagePath: 'assets/hoodie.png',
    ),
  ];

  // user cart
  List<Product> _cart = [];

  // get product list
  List<Product> get shop => _shop;

  // get user cart
  List<Product> get cart => _cart;

  // add item to cart
  void addToCart(Product item) {
    _cart.add(item);
    notifyListeners();
  }

  // remove item from cart
  void removeFromCart(Product item) {
    _cart.remove(item);
    notifyListeners();
  }
}
