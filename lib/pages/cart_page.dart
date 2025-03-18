import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/my_button.dart';
import '../components/my_cart_item_tile.dart';
import '../models/shop.dart';
import '../services/firestore_template.dart';
import '../services/promocode.dart'; 

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // For promo code input
  final TextEditingController _promoCodeController = TextEditingController();

  // Holds the discount percentage from a valid promo code
  int _discountPercentage = 0;

  // Saved Payment Methods & Addresses
  List<Map<String, dynamic>> _savedCards = [];
  List<Map<String, dynamic>> _savedAddresses = [];

  // Selected Payment Method & Address
  String? _selectedCardId;     // e.g., Firestore doc ID or last4 reference
  String? _selectedAddressId;  // e.g., Firestore doc ID

  // For showing errors (if any)
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
    _loadSavedAddresses();
  }

  /// Loads all saved cards from Firestore
  Future<void> _loadSavedCards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // not logged in
      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .get();

      setState(() {
        _savedCards = snapshot.docs.map((doc) {
          final data = doc.data();
          // You can store the doc ID or partial info (e.g., last4) as an identifier
          return {
            'id': doc.id,
            'cardNumber': data['cardNumber'] ?? '',
            'expiryDate': data['expiryDate'] ?? '',
            'cvc': data['cvc'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading cards: $e';
      });
    }
  }

  /// Loads all saved addresses from Firestore
  Future<void> _loadSavedAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // not logged in
      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Shipping and Billing Address')
          .get();

      setState(() {
        _savedAddresses = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
            'shippingLine1': data['shippingLine1'] ?? '',
            'billingLine1': data['billingLine1'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading addresses: $e';
      });
    }
  }

  /// Applies a promo code by checking Firestore (via PromoCodeService)
  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _discountPercentage = 0;
      });
      return;
    }

    final promoService = PromoCodeService();
    final promo = await promoService.getPromoCode(code);
    if (promo != null) {
      // Valid code
      setState(() {
        _discountPercentage = promo.discountPercentage;
        _errorMessage = '';
      });
    } else {
      // Invalid code
      setState(() {
        _discountPercentage = 0;
        _errorMessage = 'Invalid promo code: $code';
      });
    }
  }

  /// Calculates the total price (price * quantity) of the cart items
  double _calculateSubtotal(List<CartItem> cart) {
    double total = 0.0;
    for (final cartItem in cart) {
      total += cartItem.product.price * cartItem.quantity;
    }
    return total;
  }

  /// Pay button pressed
  Future<void> payNow() async {
    final shopProvider = context.read<Shop>();
    final cart = shopProvider.cart;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    // Calculate the base subtotal
    final subtotal = _calculateSubtotal(cart);

    // Convert percentage discount to decimal
    final discount = subtotal * (_discountPercentage / 100.0);
    final finalTotal = subtotal - discount;

    // Attempt to create an order in Firestore
    try {
      await FirestoreService().createOrder(
        userId: userId,
        cartItems: cart,
        totalPrice: finalTotal,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Order Placed'),
          content: Text(
            'Your order has been successfully created!\n'
            'Payment Method: ${_selectedCardId ?? "None selected"}\n'
            'Shipping Address: ${_selectedAddressId ?? "None selected"}',
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
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
    final cart = context.watch<Shop>().cart;
    final subtotal = _calculateSubtotal(cart);
    final discountAmount = subtotal * (_discountPercentage / 100.0);
    final finalTotal = subtotal - discountAmount;

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

              // If there's an error (e.g., invalid promo code)
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // PROMO CODE INPUT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promoCodeController,
                        decoration: InputDecoration(
                          labelText: 'Promo Code',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _promoCodeController.clear();
                              setState(() {
                                _discountPercentage = 0;
                                _errorMessage = '';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _applyPromoCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // SELECT PAYMENT METHOD (Dropdown)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
                child: DropdownButtonFormField<String>(
                  value: _selectedCardId,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: _savedCards.map((card) {
                    final cardNumber = card['cardNumber'] as String;
                    final last4 = cardNumber.length >= 4
                        ? cardNumber.substring(cardNumber.length - 4)
                        : cardNumber;
                    return DropdownMenuItem(
                      value: card['id'] as String,
                      child: Text('Card ending in ****$last4'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCardId = value;
                    });
                  },
                ),
              ),

              // SELECT SHIPPING ADDRESS (Dropdown)
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
                child: DropdownButtonFormField<String>(
                  value: _selectedAddressId,
                  decoration: const InputDecoration(
                    labelText: 'Shipping Address',
                    border: OutlineInputBorder(),
                  ),
                  items: _savedAddresses.map((address) {
                    final firstName = address['firstName'] as String;
                    final lastName = address['lastName'] as String;
                    final shipping = address['shippingLine1'] as String;
                    final display = '$firstName $lastName, $shipping';
                    return DropdownMenuItem(
                      value: address['id'] as String,
                      child: Text(display),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAddressId = value;
                    });
                  },
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
                          final cartItem = cart[index];
                          return MyCartItemTile(item: cartItem);
                        },
                      ),
              ),

              // GREY BOX: Summaries (Subtotal, discount, final total)
              if (cart.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                      Text('Savings from Promo Code: -\$${discountAmount.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      Text(
                        'Total: \$${finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

              // Pay button
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    Expanded(
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
