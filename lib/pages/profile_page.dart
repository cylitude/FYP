import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TextEditingControllers for Profile Fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _shippingLine1Controller = TextEditingController();
  final TextEditingController _shippingLine2Controller = TextEditingController();
  final TextEditingController _billingLine1Controller = TextEditingController();
  final TextEditingController _billingLine2Controller = TextEditingController();

  // Optional: Display errors if something goes wrong
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Fetches the user's existing profile data from Firestore and
  /// sets the text fields accordingly.
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged-in user found. Please sign in first.';
        });
        return;
      }

      final uid = user.uid;

      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() ?? {};
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _shippingLine1Controller.text = data['shippingLine1'] ?? '';
          _shippingLine2Controller.text = data['shippingLine2'] ?? '';
          _billingLine1Controller.text = data['billingLine1'] ?? '';
          _billingLine2Controller.text = data['billingLine2'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile data: $e';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _shippingLine1Controller.dispose();
    _shippingLine2Controller.dispose();
    _billingLine1Controller.dispose();
    _billingLine2Controller.dispose();
    super.dispose();
  }

  // Helper method to get label color:
  // If the field is empty, label is light blue; if not, label is black.
  Color _getLabelColor(String text) {
    return text.trim().isEmpty ? Colors.lightBlue : Colors.black;
  }

  // Save data to Firestore
  Future<void> _saveAndContinue() async {
    try {
      // 1. Get the currently logged-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged-in user found. Please sign in first.';
        });
        return;
      }
      final uid = user.uid;

      // 2. Basic validation (First & Last Name)
      if (_firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in at least First Name and Last Name.';
        });
        return;
      }

      // 3. Gather form data
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final shippingLine1 = _shippingLine1Controller.text.trim();
      final shippingLine2 = _shippingLine2Controller.text.trim();
      final billingLine1 = _billingLine1Controller.text.trim();
      final billingLine2 = _billingLine2Controller.text.trim();

      // 4. Save to Firestore (under "users" collection, doc = uid)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'shippingLine1': shippingLine1,
        'shippingLine2': shippingLine2,
        'billingLine1': billingLine1,
        'billingLine2': billingLine2,
      }, SetOptions(merge: true));

      // 5. Clear any error message
      setState(() {
        _errorMessage = '';
      });

      // 6. Check if widget is still mounted before using context
      if (!mounted) return;

      // 7. Navigate back to the previous page
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Decoration for TextFields
    final baseDecoration = InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
      fillColor: Colors.transparent,
      filled: true,
      // We'll set the labelStyle dynamically for each field,
      // so we keep a default here if needed.
      labelStyle: const TextStyle(color: Colors.black),
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400, // less bold
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Optional heading
                Text(
                  'Update Your Profile',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),

                // Error message if any
                if (_errorMessage.isNotEmpty) ...[
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // First Name
                TextField(
                  controller: _firstNameController,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'First Name',
                    // If empty, label = light blue, else black
                    labelStyle: TextStyle(
                      color: _getLabelColor(_firstNameController.text),
                    ),
                  ),
                  // Rebuild so label color changes if user types or deletes
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Last Name
                TextField(
                  controller: _lastNameController,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_lastNameController.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Shipping Address Line 1
                TextField(
                  controller: _shippingLine1Controller,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'Shipping Address Line 1',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_shippingLine1Controller.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Shipping Address Line 2
                TextField(
                  controller: _shippingLine2Controller,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'Shipping Address Line 2',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_shippingLine2Controller.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Billing Address Line 1
                TextField(
                  controller: _billingLine1Controller,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'Billing Address Line 1',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_billingLine1Controller.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Billing Address Line 2
                TextField(
                  controller: _billingLine2Controller,
                  cursorColor: Colors.black,
                  decoration: baseDecoration.copyWith(
                    labelText: 'Billing Address Line 2',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_billingLine2Controller.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),

      // Bottom area with 3 buttons
      bottomNavigationBar: Container(
        color: Colors.grey[300],
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

            // Save and Exit button
            ElevatedButton(
              onPressed: _saveAndContinue,
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
