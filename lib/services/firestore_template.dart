import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop.dart'; // for CartItem, Product

class FirestoreService {
  // Reference to the 'orders' collection in Firestore
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // CREATE: Add a new order to Firestore
  Future<void> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required double totalPrice,
  }) {
    // Convert each CartItem to a Map for Firestore
    final itemsData = cartItems.map((cartItem) {
      return {
        'name': cartItem.product.name,
        'price': cartItem.product.price,
        'description': cartItem.product.description,
        'imagePath': cartItem.product.imagePath,
        'size': cartItem.size, // store the chosen size
      };
    }).toList();

    return orders.add({
      'userId': userId,          // which user placed the order
      'items': itemsData,        // list of items (product + size) in the order
      'totalPrice': totalPrice,  // total price of this order
      'timestamp': Timestamp.now(),
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
