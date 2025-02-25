import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_template.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user ID; if no user is logged in, fallback to 'guest'
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders", style: GoogleFonts.dmSerifDisplay()),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getOrdersStream(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If there are no orders for the user
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders found.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18),
              ),
            );
          }

          // Retrieve the list of orders from Firestore
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              // Each document contains the order data
              final orderData =
                  orders[index].data() as Map<String, dynamic>;
              final totalPrice = orderData['totalPrice'] as num;
              final timestamp = orderData['timestamp'] as Timestamp;
              final orderId = orders[index].id;
              final items = orderData['items'] as List<dynamic>;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text('Order ID: $orderId',
                      style: GoogleFonts.dmSerifDisplay(fontSize: 16)),
                  subtitle: Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}\n'
                    'Date: ${timestamp.toDate().toLocal().toString().split('.')[0]}\n'
                    'Items: ${items.length}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Optionally, navigate to an order detail page
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
