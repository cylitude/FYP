import 'package:flutter/material.dart';
import 'product.dart';
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
  
  final List<Product> _shop = [
    Product(
      name: "Cotton White Shirt",
      price: 58.88,
      description: "Perfect for a casual date",
      imagePath: 'assets/FormalWhiteShirt.png',
      keywords: [
        'cotton', 'white', 'shirt', 'casual', 'date',
        'long-sleeve', 'button-down', 'collar',
        'spring', 'wrinkle-resistant', 'soft', 'neutral',
        'formal', 'semi-formal', 'staple', 'minimal', 'slim-fit', 'tailored', 
        'everyday', 'office',
      ],
    ),
    Product(
      name: "Crochet Shirt",
      price: 78.88,
      description: "Perfect for the beach",
      imagePath: 'assets/CrochetShirt.png',
      keywords: [
        'crochet', 'shirt', 'beach', 'summer', 'short-sleeve',
        'knit', 'handmade', 'textured', 'lightweight', 'airy',
        'casual', 'festival', 'vacation', 'resort', 'breezy',
        'layered', 'crochet-pattern', 'fringe', 'bohemian', 'vintage',
        'crochet-top', 'crochet-blouse', 'pastel', 
        'cropped', 'swim-cover', 'artisan', 'seaside', 'relaxed-fit',
      ],
    ),
    Product(
      name: "Oxford Black Shirt",
      price: 88.88,
      description: "Perfect for date nights",
      imagePath: 'assets/FormalBlackShirt.png',
      keywords: [
        'oxford', 'black', 'shirt', 'formal', 'date',
        'dress', 'classic', 'button-down', 'long-sleeve', 'collar',
        'slim-fit', 'tailored', 'office', 'evening', 'night-out',
        'versatile', 'neutral', 'sleek', 'polished', 'menswear',
        'business', 'professional', 'elegant', 'timeless', 'preppy', 
        'fabric-blend', 'durable', 
      ],
    ),
    Product(
      name: "Boxy Blue Shirt",
      price: 68.88,
      description: "Boxy, oversized fit",
      imagePath: 'assets/BlueBoxyShirt.png',
      keywords: [
        'boxy', 'blue', 'shirt', 'oversized', 'street',
        'casual', 'urban', 'denim-look', 'chambray', 'relaxed-fit',
        'boxy-cut', 'loose', 'comfortable', 'menswear-inspired', 'unisex',
        'pastel', 'light-blue', 'summer', 'layering', 'trendy',
        'edgy', 'minimalist', 'hipster', 'cotton-blend', 'breathable',
        'daily-wear', 'lounge', 'denim-inspired', 'short-sleeve', 'drop-shoulder',
      ],
    ),
  ];

  final List<CartItem> _cart = [];

  List<Product> get shop => _shop;
  List<CartItem> get cart => _cart;

  void addToCart(Product product, String size) {
    final idx = _cart.indexWhere((c) =>
      c.product.name == product.name && c.size == size
    );
    if (idx != -1) {
      _cart[idx].quantity++;
    } else {
      _cart.add(CartItem(product: product, size: size));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cart.remove(item);
    }
    notifyListeners();
  }
}
