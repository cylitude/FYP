import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  // Controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  // For displaying saved payment methods
  List<Map<String, dynamic>> _savedCards = [];

  // Error or status messages
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  /// Load saved payment methods from Firestore for the current user
  Future<void> _loadSavedCards() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user is currently logged in.';
        });
        return;
      }

      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .get();

      final cardsData = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        _savedCards = cardsData.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading cards: $e';
      });
    }
  }

  /// Saves a new card to Firestore
  Future<void> _saveCard() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No user is currently logged in.';
        });
        return;
      }

      final uid = user.uid;

      final cardNumber = _cardNumberController.text.trim();
      final expiryDate = _expiryDateController.text.trim();
      final cvc = _cvcController.text.trim();

      // Basic validation
      if (cardNumber.length != 16 ||
          expiryDate.length != 5 || 
          cvc.length != 3) {
        setState(() {
          _errorMessage =
              'Please check your card details (16-digit number, valid MM/YY, and 3-digit CVC).';
        });
        return;
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .add({
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvc': cvc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form
      _cardNumberController.clear();
      _expiryDateController.clear();
      _cvcController.clear();

      // Refresh the list of saved cards
      _loadSavedCards();

      setState(() {
        _errorMessage = ''; // Clear any previous error
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving card: $e';
      });
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final baseDecoration = InputDecoration(
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      fillColor: Colors.white,
      filled: true,
      labelStyle: const TextStyle(color: Colors.black), 
      hintStyle: const TextStyle(color: Colors.black),  
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title: Add New Payment Information
            const Text(
              'Add New Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Error message if any
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Card Number
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              maxLength: 16, // ensure only 16 digits
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // digits only
                LengthLimitingTextInputFormatter(16),
              ],
              cursorColor: Colors.black,
              decoration: baseDecoration.copyWith(
                labelText: 'Card Number',
                hintText: 'Enter 16-digit card number',
                counterText: '', // hide the counter from maxLength
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date (MM/YY)
            TextField(
              controller: _expiryDateController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                ExpiryDateFormatter(),
              ],
              cursorColor: Colors.black,
              decoration: baseDecoration.copyWith(
                labelText: 'MM/YY',
                hintText: 'Enter expiry date',
              ),
            ),
            const SizedBox(height: 16),

            // CVC
            TextField(
              controller: _cvcController,
              keyboardType: TextInputType.number,
              maxLength: 3,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              cursorColor: Colors.black,
              decoration: baseDecoration.copyWith(
                labelText: 'CVC',
                hintText: 'Enter 3-digit CVC',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveCard,
                child: const Text(
                  'SAVE PAYMENT METHOD',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title: Saved Payment Methods
            const Text(
              'Saved Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // List of saved cards
            if (_savedCards.isEmpty)
              const Text('No saved payment methods yet.'),
            if (_savedCards.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedCards.length,
                itemBuilder: (context, index) {
                  final cardData = _savedCards[index];
                  final fullNumber = cardData['cardNumber'] ?? '';
                  final last4 = fullNumber.length >= 4
                      ? fullNumber.substring(fullNumber.length - 4)
                      : fullNumber; // fallback if not 16 digits
                  final expiryDate = cardData['expiryDate'] ?? '';
                  final cvc = cardData['cvc'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      // Show the full card info in a dialog
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Card Details'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card Number: $fullNumber'),
                                Text('Expiry Date: $expiryDate'),
                                Text('CVC: $cvc'),
                              ],
                            ),
                            actions: [
                              // Updated: ElevatedButton with black background & white text
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
                              ),
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
                      child: Row(
                        children: [
                          const Icon(Icons.credit_card, size: 32),
                          const SizedBox(width: 12),
                          Text('Card ending with ****$last4'),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom TextInputFormatter for expiry date (MM/YY).
/// Ensures only digits, inserts a slash after the first 2 digits, and
/// caps the total length to 5 chars (e.g., "06/25").
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 4 digits max (MMYY)
    if (digitsOnly.length > 4) {
      digitsOnly = digitsOnly.substring(0, 4);
    }

    // Insert slash after 2 digits (MM/YY)
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    // Maintain correct cursor position
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
