import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMeasurementPage extends StatefulWidget {
  const BodyMeasurementPage({super.key});

  @override
  State<BodyMeasurementPage> createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage>
    with SingleTickerProviderStateMixin {
  // Tab controller for switching between Basic and Advanced
  late TabController _tabController;

  // TextEditingControllers for Basic Measurements
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _shoeSizeController = TextEditingController();

  // TextEditingControllers for Advanced Measurements (Optional)
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _legLengthController = TextEditingController();

  // Gender dropdown
  String _selectedGender = 'Male';

  // Optional: You can display errors to the user if something goes wrong
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _shoeSizeController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _waistController.dispose();
    _legLengthController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    try {
      // 1. Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged in user found.';
        });
        return;
      }
      final uid = user.uid;

      // 2. Gather all form data
      final gender = _selectedGender;
      final height = _heightController.text.trim();
      final weight = _weightController.text.trim();
      final shoeSize = _shoeSizeController.text.trim();

      // -- ADVANCED FIELDS (OPTIONAL) --
      final chest = _chestController.text.trim();
      final shoulder = _shoulderController.text.trim();
      final waist = _waistController.text.trim();
      final legLength = _legLengthController.text.trim();

      // 3. Basic validation: only check the required fields
      if (height.isEmpty || weight.isEmpty || shoeSize.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in the required basic fields.';
        });
        return;
      }

      // 4. Save to Firestore (users collection, doc = user.uid)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'gender': gender,
        'height': height,
        'weight': weight,
        'shoeSize': shoeSize, // EUR shoe size
        // Advanced fields are optional; store them even if empty
        'chest': chest,
        'shoulder': shoulder,
        'waist': waist,
        'legLength': legLength,
      }, SetOptions(merge: true));

      // 5. Navigate to the next page
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/shop_page');
    } catch (e) {
      // Catch any errors and display them
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Updated InputDecoration to remove the white fill
    // and only change the border color on focus.
    final baseDecoration = InputDecoration(
      labelStyle: const TextStyle(color: Colors.black),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      // Only the border turns black and thicker when focused
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
      // Make fill color transparent or match the background so it doesn't go white
      fillColor: Colors.transparent,
      filled: true,
    );

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Measurements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.grey[300],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'BASIC'),
                Tab(text: 'ADVANCED'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // BASIC Measurements Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Gender',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Height
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Height (cm)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Weight
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Weight (kg)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Shoe Size (EUR)
                  TextField(
                    controller: _shoeSizeController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Shoe Size (EUR)',
                    ),
                  ),
                ],
              ),
            ),

            // ADVANCED Measurements Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Chest Circumference
                  TextField(
                    controller: _chestController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Chest Circumference (cm)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Shoulder Width
                  TextField(
                    controller: _shoulderController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Shoulder Width (cm)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Waist Circumference
                  TextField(
                    controller: _waistController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Waist Circumference (cm)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Leg Length
                  TextField(
                    controller: _legLengthController,
                    keyboardType: TextInputType.number,
                    decoration: baseDecoration.copyWith(
                      labelText: 'Leg Length (cm)',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[300],
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                // Force the button to expand horizontally and be taller
                minimumSize: const Size(double.infinity, 80),
                padding: const EdgeInsets.symmetric(vertical: 30),
              ),
              child: const Text(
                'SAVE AND CONTINUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
