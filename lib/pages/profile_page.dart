import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to dark mode changes from your ThemeProvider.
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: true).isDarkMode;
    // Black text in light mode, white text in dark mode.
    final darkModeTextColor = isDarkMode ? Colors.white : Colors.black;
    // Get current user's uid; if not logged in, use a test uid.
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'testUserId';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(
          'Account',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Dynamic Progress Indicator Card
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('userId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Sum the totalPrice of all orders for this user
                    double totalSpent = 0.0;
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      totalSpent += (data['totalPrice'] ?? 0).toDouble();
                    }
                    final spent = totalSpent;

                    // Determine tier and progress
                    String tier;
                    double progressFraction;
                    double nextLevelAmount;
                    Color startColor;
                    Color endColor;

                    if (spent <= 200) {
                      tier = "Bronze";
                      nextLevelAmount = 200.0;
                      progressFraction = spent / nextLevelAmount;
                      startColor = Colors.brown.shade300;
                      endColor = Colors.brown.shade500;
                    } else if (spent > 200 && spent <= 1000) {
                      tier = "Silver";
                      nextLevelAmount = 1000.0;
                      progressFraction = (spent - 200) / (1000 - 200);
                      startColor = Colors.grey.shade400;
                      endColor = Colors.grey.shade600;
                    } else {
                      tier = "Silver";
                      nextLevelAmount = 1000.0;
                      progressFraction = 1.0;
                      startColor = Colors.grey.shade400;
                      endColor = Colors.grey.shade600;
                    }
                    progressFraction = progressFraction.clamp(0.0, 1.0);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            colors: [startColor, endColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tier,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Level Progress',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4.0),
                            LinearProgressIndicator(
                              value: progressFraction,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 8.0,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('US\$${spent.toStringAsFixed(0)}'),
                                Text('US\$${nextLevelAmount.toStringAsFixed(0)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Static Membership Table
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(3),
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300),
                        outside: BorderSide(color: Colors.grey.shade400),
                      ),
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(12.0),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'MEMBERSHIP LEVEL',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'BENEFITS',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Bronze row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.brown[300],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Bronze',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'No benefits',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Silver row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Silver',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '10% discount on all items',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Gold row
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.amber[400],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Gold',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                '20% discount on all items',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark Mode Toggle (positioned just above the Measurements button)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkModeTextColor,
                    ),
                  ),
                  CupertinoSwitch(
                    onChanged: (value) =>
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(),
                    value: isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Measurements button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/measurements_page');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text(
                'MEASUREMENTS',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Payment Details button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/paymentdetails_page');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text(
                'PAYMENT DETAILS',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Manage Addresses button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addressdetails_page');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text(
                'MANAGE ADDRESSES',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Save and Exit button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/shop_page');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              child: const Text(
                'SAVE AND EXIT',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
