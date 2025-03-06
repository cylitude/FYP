import 'package:flutter/material.dart';
import 'product.dart';

class Shop extends ChangeNotifier {
  // products for sale
  final List<Product> _shop = [
    // product 1
    Product(
      name: "White Shirt",
      price: 58.88,
      description: "Perfect for a casual date",
      imagePath: 'assets/WhiteShirt.png',
    ),
    // product 2
    Product(
      name: "Air Jordans 1",
      price: 188.88,
      description: "Fly high like Michael Jordan",
      imagePath: 'assets/AirJordans1.png',
    ),
    // product 3
    Product(
      name: "Heizer G1",
      price: 288.88,
      description: "A modern and minimalistic pair of sunglasses.",
      imagePath: 'assets/HeizerG1.png',
    ),
    // product 4
    Product(
      name: "Supreme Hoodie",
      price: 688.88,
      description: "Made of 100% Cashmere",
      imagePath: 'assets/BlackSupremeHoodie.png',
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

  // clear the entire cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
