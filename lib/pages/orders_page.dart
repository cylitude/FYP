import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_template.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // Build a list of item detail widgets
  List<Widget> _buildOrderItems(List<dynamic> items) {
    return items.map((item) {
      final productName = item['name'] as String? ?? 'Unknown Product';
      final description = item['description'] as String? ?? 'No description';
      final price = item['price'] as num? ?? 0;
      final size = item['size'] as String? ?? 'N/A';
      final quantity = item['quantity'] as int? ?? 1;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text('Description: $description', style: const TextStyle(fontSize: 13)),
            Text('Price: \$${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
            Text('Size: $size', style: const TextStyle(fontSize: 13)),
            Text('Quantity: $quantity', style: const TextStyle(fontSize: 13)),
          ],
        ),
      );
    }).toList();
  }

  // Show order details in a pop-up dialog
  void _showOrderDetails(
    BuildContext context,
    Map<String, dynamic> orderData,
    int orderNumber,
  ) {
    final userId = orderData['userId'] as String? ?? 'Unknown User';
    final totalPrice = orderData['totalPrice'] as num? ?? 0;
    final timestamp = orderData['timestamp'] as Timestamp?;
    final items = orderData['items'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Order #$orderNumber Details",
            style: GoogleFonts.dmSerifDisplay(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("User ID: $userId"),
                const SizedBox(height: 8),
                Text("Total Price: \$${totalPrice.toStringAsFixed(2)}"),
                const SizedBox(height: 8),
                Text(
                  "Timestamp: ${timestamp != null ? timestamp.toDate().toLocal().toString().split('.')[0] : 'N/A'}",
                ),
                const SizedBox(height: 12),

                // Items
                const Text(
                  "Items:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ..._buildOrderItems(items),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders found.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 18,
                ),
              ),
            );
          }

          // Retrieve the list of order documents from Firestore
          final orderDocs = snapshot.data!.docs;

          // Sort orders by timestamp ascending (earliest first)
          orderDocs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTimestamp = aData['timestamp'] as Timestamp;
            final bTimestamp = bData['timestamp'] as Timestamp;
            return aTimestamp.compareTo(bTimestamp);
          });

          return ListView.builder(
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData = orderDocs[index].data() as Map<String, dynamic>;
              final totalPrice = orderData['totalPrice'] as num? ?? 0;
              final timestamp = orderData['timestamp'] as Timestamp?;
              final items = orderData['items'] as List<dynamic>? ?? [];

              // Instead of items.length, sum the 'quantity' field in each item
              int totalQuantity = 0;
              for (final item in items) {
                final quantity = item['quantity'] as int? ?? 1;
                totalQuantity += quantity;
              }

              // Use the chronological position to display Order # (earliest = #1)
              final orderNumber = index + 1;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(
                    'Order #$orderNumber',
                    style: GoogleFonts.dmSerifDisplay(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}\n'
                    'Date: ${timestamp != null ? timestamp.toDate().toLocal().toString().split('.')[0] : 'N/A'}\n'
                    'Items: $totalQuantity',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Show detailed order info in a pop-up dialog
                    _showOrderDetails(context, orderData, orderNumber);
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
