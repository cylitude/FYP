import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  // Reference to the 'orders' collection in Firestore
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // CREATE: Add a new order to Firestore
  Future<void> createOrder({
    required String userId,
    required List<Product> cartItems,
    required double totalPrice,
  }) {
    // Convert each Product in cartItems to a Map for Firestore
    final itemsData = cartItems.map((product) {
      return {
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imagePath': product.imagePath,
      };
    }).toList();

    return orders.add({
      'userId': userId,          // which user placed the order
      'items': itemsData,        // list of products in the order
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
