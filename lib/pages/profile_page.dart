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
  final TextEditingController _billingLine1Controller = TextEditingController();

  // Optional: Display errors if something goes wrong
  String _errorMessage = '';

  // List to hold saved addresses
  List<Map<String, dynamic>> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAddresses();
  }

  /// Loads the main profile data (first and last name)
  Future<void> _loadProfileData() async {
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
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile data: $e';
      });
    }
  }

  /// Loads all saved addresses from the subcollection "Shipping and Billing Address"
  Future<void> _loadAddresses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Shipping and Billing Address')
          .get();
      setState(() {
        _savedAddresses =
            querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading addresses: $e';
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _shippingLine1Controller.dispose();
    _billingLine1Controller.dispose();
    super.dispose();
  }

  // Helper method to get label color: light blue if field is empty, black otherwise.
  Color _getLabelColor(String text) {
    return text.trim().isEmpty ? Colors.lightBlue : Colors.black;
  }

  /// Saves the main profile data (first and last name) into the "users" document.
  /// (Addresses are saved separately using the "Save Address" button.)
  Future<void> _saveAndContinue() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged-in user found. Please sign in first.';
        });
        return;
      }
      final uid = user.uid;

      // Basic validation for first and last name
      if (_firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in at least First Name and Last Name.';
        });
        return;
      }

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Save to the main "users" document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
      }, SetOptions(merge: true));

      setState(() {
        _errorMessage = '';
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  /// Saves a new shipping and billing address into a subcollection.
  Future<void> _saveAddress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged-in user found. Please sign in first.';
        });
        return;
      }
      final uid = user.uid;
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final shippingLine1 = _shippingLine1Controller.text.trim();
      final billingLine1 = _billingLine1Controller.text.trim();

      // Basic validation: require all these fields for saving an address
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          shippingLine1.isEmpty ||
          billingLine1.isEmpty) {
        setState(() {
          _errorMessage =
              'Please fill in First Name, Last Name, Shipping Address Line 1, and Billing Address Line 1.';
        });
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Shipping and Billing Address')
          .add({
        'firstName': firstName,
        'lastName': lastName,
        'shippingLine1': shippingLine1,
        'billingLine1': billingLine1,
      });

      // Clear the address fields after saving
      _shippingLine1Controller.clear();
      _billingLine1Controller.clear();
      setState(() {
        _errorMessage = '';
      });
      _loadAddresses();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving address: $e';
      });
    }
  }

  /// Builds a widget displaying the list of saved addresses.
  Widget _buildSavedAddresses() {
    if (_savedAddresses.isEmpty) {
      return const Text('No saved addresses yet.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedAddresses.length,
      itemBuilder: (context, index) {
        final address = _savedAddresses[index];
        final fullName =
            '${address['firstName'] ?? ''} ${address['lastName'] ?? ''}';
        final shipping = address['shippingLine1'] ?? '';
        final billing = address['billingLine1'] ?? '';
        return GestureDetector(
          onTap: () {
            // Show full address details in a dialog
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: const Text('Address Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $fullName'),
                      const SizedBox(height: 8),
                      const Text('Shipping Address:'),
                      Text(shipping),
                      const SizedBox(height: 8),
                      const Text('Billing Address:'),
                      Text(billing),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('CLOSE',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Shipping: $shipping'),
                Text('Billing: $billing'),
              ],
            ),
          ),
        );
      },
    );
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
      labelStyle: const TextStyle(color: Colors.black),
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w400,
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
                Text(
                  'Update Your Profile',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16),
                // Display error message if any
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
                    labelStyle: TextStyle(
                      color: _getLabelColor(_firstNameController.text),
                    ),
                  ),
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
                    labelText: 'Shipping Address Line',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_shippingLine1Controller.text),
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
                    labelText: 'Billing Address Line',
                    labelStyle: TextStyle(
                      color: _getLabelColor(_billingLine1Controller.text),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // "Save Address" button for adding a new address
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SAVE ADDRESS',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Display list of saved addresses
                const Text(
                  'Saved Addresses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildSavedAddresses(),
              ],
            ),
          ),
        ),
      ),
      // Bottom area with 3 buttons (unchanged)
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
