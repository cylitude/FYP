import 'package:flutter/material.dart';
import 'product.dart';

/// Represents a single item in the cart: a Product + chosen size + quantity
class CartItem {
  final Product product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });
}

class Shop extends ChangeNotifier {
  // Products for sale
  final List<Product> _shop = [
    Product(
      name: "Cotton White Shirt",
      price: 58.88,
      description: "Perfect for a casual date",
      imagePath: 'assets/FormalWhiteShirt.png',
    ),
    Product(
      name: "Crochet Shirt",
      price: 78.88,
      description: "Perfect for the beach",
      imagePath: 'assets/CrochetShirt.png',
    ),
    Product(
      name: "Oxford Black Shirt",
      price: 88.88,
      description: "Perfect for date nights",
      imagePath: 'assets/FormalBlackShirt.png',
    ),
    Product(
      name: "Boxy Blue Shirt",
      price: 68.88,
      description: "Boxy, oversized fit",
      imagePath: 'assets/BlueBoxyShirt.png',
    ),
  ];

  // The cart is now a list of CartItem
  final List<CartItem> _cart = [];

  // Get product list
  List<Product> get shop => _shop;

  // Get user cart
  List<CartItem> get cart => _cart;

  /// Add item to cart, specifying the chosen size.
  /// If the same product & size is already in the cart, just increment quantity.
  void addToCart(Product product, String size) {
    final existingIndex = _cart.indexWhere((cartItem) =>
        cartItem.product.name == product.name && cartItem.size == size);

    if (existingIndex != -1) {
      // Already in cart => increment the quantity
      _cart[existingIndex].quantity++;
    } else {
      // Not in cart => add a new CartItem
      _cart.add(CartItem(product: product, size: size, quantity: 1));
    }
    notifyListeners();
  }

  /// Remove entire item from cart
  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  /// Clear the entire cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Increase quantity of a given CartItem
  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  /// Decrease quantity of a given CartItem.
  /// If quantity reaches 0, remove it from the cart.
  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cart.remove(item);
    }
    notifyListeners();
  }
}
