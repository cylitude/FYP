import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressDetailsPage extends StatefulWidget {
  // Convert 'key' to a super parameter by using `super.key`
  const AddressDetailsPage({super.key});

  @override
  State<AddressDetailsPage> createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  // TextEditingControllers for Profile Fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _shippingLine1Controller = TextEditingController();
  final TextEditingController _billingLine1Controller = TextEditingController();

  // Display errors if something goes wrong
  String _errorMessage = '';

  // List to hold saved addresses
  List<Map<String, dynamic>> _savedAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAddresses();
  }

  /// Loads the main profile data (first and last name) from Firestore
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

      // Basic validation: require these fields for saving an address
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          shippingLine1.isEmpty ||
          billingLine1.isEmpty) {
        setState(() {
          _errorMessage =
              'Please fill in First Name, Last Name, Shipping Address Line, and Billing Address Line.';
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

      // Reload addresses to reflect newly added entry
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
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(color: Colors.white),
                      ),
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
                Text(
                  fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
      appBar: AppBar(
        title: Text(
          'Update Your Address',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 24,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // "Save Address" button
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
    );
  }
}
