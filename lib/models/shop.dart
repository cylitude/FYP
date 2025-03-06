import 'package:flutter/material.dart';
import 'product.dart';

/// Represents a single item in the cart: a Product + chosen size.
class CartItem {
  final Product product;
  final String size;

  CartItem({required this.product, required this.size});
}

class Shop extends ChangeNotifier {
  // products for sale
  final List<Product> _shop = [
    // product 1
    Product(
      name: "Cotton White Shirt",
      price: 58.88,
      description: "Perfect for a casual date",
      imagePath: 'assets/FormalWhiteShirt.png',
    ),
    // product 2
    Product(
      name: "Crochet Shirt",
      price: 78.88,
      description: "Perfect for the beach",
      imagePath: 'assets/CrochetShirt.png',
    ),
    // product 3
    Product(
      name: "Oxford Black Shirt",
      price: 88.88,
      description: "Perfect for date nights",
      imagePath: 'assets/FormalBlackShirt.png',
    ),
    // product 4
    Product(
      name: "Boxy Blue Shirt",
      price: 688.88,
      description: "Boxy, oversized fit",
      imagePath: 'assets/BlueBoxyShirt.png',
    ),
  ];

  // The cart is now a list of CartItem
  List<CartItem> _cart = [];

  // get product list
  List<Product> get shop => _shop;

  // get user cart
  List<CartItem> get cart => _cart;

  // Add item to cart, specifying the chosen size
  void addToCart(Product product, String size) {
    _cart.add(CartItem(product: product, size: size));
    notifyListeners();
  }

  // remove item from cart
  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  // clear the entire cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
