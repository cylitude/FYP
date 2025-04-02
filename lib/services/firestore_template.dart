import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart'; // for CartItem, Product

class FirestoreService {
  // Reference to the 'orders' collection in Firestore
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // CREATE: Add a new order to Firestore, with optional shipping and payment info.
  Future<void> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required double totalPrice,
    Map<String, dynamic>? shippingAddress,  // New field
    Map<String, dynamic>? paymentMethod,    // New field
  }) {
    // Convert each CartItem to a Map for Firestore, including quantity
    final itemsData = cartItems.map((cartItem) {
      return {
        'name': cartItem.product.name,
        'price': cartItem.product.price,
        'description': cartItem.product.description,
        'imagePath': cartItem.product.imagePath,
        'size': cartItem.size,
        'quantity': cartItem.quantity, // store the chosen quantity
      };
    }).toList();

    return orders.add({
      'userId': userId,               // which user placed the order
      'items': itemsData,             // list of items (product + size + quantity)
      'totalPrice': totalPrice,       // total price of this order
      'timestamp': Timestamp.now(),
      'shippingAddress': shippingAddress ?? {},
      'paymentMethod': paymentMethod ?? {},
    });
  }

  // READ: Get all orders for a specific user (optional)
  Stream<QuerySnapshot> getOrdersStream(String userId) {
    return orders
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // UPDATE: Update an order by doc ID (optional)
  Future<void> updateOrder(String docId, Map<String, dynamic> updatedData) {
    return orders.doc(docId).update(updatedData);
  }

  // DELETE: Delete an order by doc ID (optional)
  Future<void> deleteOrder(String docId) {
    return orders.doc(docId).delete();
  }
}
