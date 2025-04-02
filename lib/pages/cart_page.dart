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
  String? _selectedCardId;
  String? _selectedAddressId;

  // For showing errors (if any)
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
    _loadSavedAddresses();
  }

  /// Loads all saved cards from Firestore.
  Future<void> _loadSavedCards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .get();

      setState(() {
        _savedCards = snapshot.docs.map((doc) {
          final data = doc.data();
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

  /// Loads all saved addresses from Firestore.
  Future<void> _loadSavedAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
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

  /// Applies a promo code by checking Firestore (via PromoCodeService).
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
      setState(() {
        _discountPercentage = promo.discountPercentage;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _discountPercentage = 0;
        _errorMessage = 'Invalid promo code: $code';
      });
    }
  }

  /// Calculates the subtotal (price * quantity) of the cart items.
  double _calculateSubtotal(List<CartItem> cart) {
    double total = 0.0;
    for (final cartItem in cart) {
      total += cartItem.product.price * cartItem.quantity;
    }
    return total;
  }

  /// For membership logic, we sum all orders from 'orders' for this user,
  /// so it mirrors the dynamic progress logic in profile_page.
  Future<double> _getTotalSpentFromOrders(String userId) async {
    final query = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    double sum = 0.0;
    for (final doc in query.docs) {
      final data = doc.data();
      sum += (data['totalPrice'] ?? 0).toDouble();
    }
    return sum;
  }

  /// Decide membership tier by totalSpent, matching profile_page logic:
  /// 0-200 => Bronze
  /// 201-1000 => Silver
  /// >1000 => Gold
  String _decideTier(double totalSpent) {
    if (totalSpent <= 200) {
      return 'Bronze';
    } else if (totalSpent > 200 && totalSpent <= 1000) {
      return 'Silver';
    } else {
      return 'Gold';
    }
  }

  /// Update membership in user doc, if it doesn't match the correct tier
  Future<void> _updateMembershipTier(String userId, String correctTier) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await docRef.get();
    final userData = userDoc.data() ?? {};
    final membership = userData['membership'] ?? 'Bronze';

    if (membership != correctTier) {
      await docRef.update({'membership': correctTier});
    }
  }

  /// Pay button pressed => Create an order in Firestore, then update membership
  /// by summing orders (not by trusting the user doc's 'spent' field).
  Future<void> _payNow({
    required double membershipDiscountPercent,
  }) async {
    final shopProvider = context.read<Shop>();
    final cart = shopProvider.cart;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    final subtotal = _calculateSubtotal(cart);
    final membershipDiscount = subtotal * membershipDiscountPercent;
    final afterMembership = subtotal - membershipDiscount;
    final promoDiscount = afterMembership * (_discountPercentage / 100.0);
    final finalTotal = afterMembership - promoDiscount;

    try {
      // Create the order in Firestore
      await FirestoreService().createOrder(
        userId: userId,
        cartItems: cart,
        totalPrice: finalTotal,
      );

      // We also increment the 'spent' field for historical reasons if you like
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.update({
        'spent': FieldValue.increment(finalTotal),
      });

      // Now recalc membership from 'orders' sum => set correct membership
      final newTotalSpent = await _getTotalSpentFromOrders(userId);
      final correctTier = _decideTier(newTotalSpent);
      await _updateMembershipTier(userId, correctTier);

      if (!mounted) return;

      // Show success pop-up
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
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Instead of streaming the user doc, we stream orders
        // so we can sum them in real-time (like profile_page).
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sum up totalSpent from all orders
          double totalSpent = 0.0;
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            totalSpent += (data['totalPrice'] ?? 0).toDouble();
          }

          // Decide tier from totalSpent
          String correctTier = 'Bronze';
          if (totalSpent > 200 && totalSpent <= 1000) {
            correctTier = 'Silver';
          } else if (totalSpent > 1000) {
            correctTier = 'Gold';
          }

          // Convert that tier to discount
          double membershipDiscountPercent = 0.0;
          if (correctTier == 'Silver') {
            membershipDiscountPercent = 0.10;
          } else if (correctTier == 'Gold') {
            membershipDiscountPercent = 0.20;
          }

          // Now compute the cart's subtotal & final total
          final subtotal = _calculateSubtotal(cart);
          final membershipDiscount = subtotal * membershipDiscountPercent;
          final afterMembership = subtotal - membershipDiscount;
          final promoDiscount = afterMembership * (_discountPercentage / 100.0);
          final finalTotal = afterMembership - promoDiscount;

          return Center(
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
                      style: GoogleFonts.dmSerifDisplay(fontSize: 32),
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

                  // PAYMENT METHOD
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

                  // SHIPPING ADDRESS with "Collect in-store" option
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedAddressId,
                      decoration: const InputDecoration(
                        labelText: 'Shipping Address',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        // Permanent "Collect in-store" option
                        const DropdownMenuItem(
                          value: 'collect_instore',
                          child: Text('Collect in-store'),
                        ),
                        // Then user's saved addresses
                        ..._savedAddresses.map((address) {
                          final firstName = address['firstName'] as String;
                          final lastName = address['lastName'] as String;
                          final shipping = address['shippingLine1'] as String;
                          final display = '$firstName $lastName, $shipping';
                          return DropdownMenuItem(
                            value: address['id'] as String,
                            child: Text(display),
                          );
                        }),
                      ],
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

                  // Summaries
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
                          Text(
                            'Membership Discount '
                            '(${(membershipDiscountPercent * 100).toStringAsFixed(0)}% - $correctTier): '
                            '-\$${membershipDiscount.toStringAsFixed(2)}',
                          ),
                          Text(
                            'Promo Code Discount '
                            '($_discountPercentage%): '
                            '-\$${promoDiscount.toStringAsFixed(2)}',
                          ),
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
                                  onTap: () => _payNow(
                                    membershipDiscountPercent: membershipDiscountPercent,
                                  ),
                                  widget: Center(
                                    child: Text(
                                      'P A Y   N O W',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.inversePrimary,
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
          );
        },
      ),
    );
  }
}
