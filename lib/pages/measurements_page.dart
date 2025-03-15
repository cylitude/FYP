import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMeasurementPage extends StatefulWidget {
  const BodyMeasurementPage({super.key});

  @override
  State<BodyMeasurementPage> createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  // TextEditingControllers for BASIC Measurements
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // TextEditingControllers for ADVANCED Measurements (Optional)
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();

  // Gender dropdown
  String _selectedGender = 'Male';

  // Optional: Display errors if something goes wrong
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  /// Loads the user's measurement data from Firestore and
  /// populates the controllers + gender dropdown.
  Future<void> _loadMeasurements() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged in user found.';
        });
        return;
      }

      final uid = user.uid;
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() ?? {};
        setState(() {
          _selectedGender = data['gender'] ?? 'Male';
          _heightController.text = data['height'] ?? '';
          _weightController.text = data['weight'] ?? '';
          _chestController.text = data['chest'] ?? '';
          _shoulderController.text = data['shoulder'] ?? '';
          _waistController.text = data['waist'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading measurements: $e';
      });
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _waistController.dispose();
    super.dispose();
  }

  /// Helper to determine label color: light blue if empty, black if filled
  Color _getLabelColor(String text) {
    return text.trim().isEmpty ? Colors.lightBlue : Colors.black;
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

      // ADVANCED FIELDS (OPTIONAL)
      final chest = _chestController.text.trim();
      final shoulder = _shoulderController.text.trim();
      final waist = _waistController.text.trim();

      // 3. Basic validation: require height & weight
      if (height.isEmpty || weight.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in the required fields (Height, Weight).';
        });
        return;
      }

      // 4. Save to Firestore (users collection, doc = user.uid)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'gender': gender,
        'height': height,      // in cm
        'weight': weight,      // in kg
        'chest': chest,
        'shoulder': shoulder,
        'waist': waist,
      }, SetOptions(merge: true));

      // 5. Navigate on success
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
    // Base InputDecoration
    final baseDecoration = InputDecoration(
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
      ),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // BASIC SECTION
              const Text(
                'BASIC',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: baseDecoration.copyWith(
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_selectedGender),
                  ),
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

              // Height (cm)
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: baseDecoration.copyWith(
                  labelText: 'Height (cm)',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_heightController.text),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Weight (kg)
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: baseDecoration.copyWith(
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_weightController.text),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 32),

              // ADVANCED SECTION
              const Text(
                'ADVANCED',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Chest Circumference
              TextField(
                controller: _chestController,
                keyboardType: TextInputType.number,
                decoration: baseDecoration.copyWith(
                  labelText: 'Chest Circumference (cm)',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_chestController.text),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Shoulder Width
              TextField(
                controller: _shoulderController,
                keyboardType: TextInputType.number,
                decoration: baseDecoration.copyWith(
                  labelText: 'Shoulder Width (cm)',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_shoulderController.text),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Waist Circumference
              TextField(
                controller: _waistController,
                keyboardType: TextInputType.number,
                decoration: baseDecoration.copyWith(
                  labelText: 'Waist Circumference (cm)',
                  labelStyle: TextStyle(
                    color: _getLabelColor(_waistController.text),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
          ),
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
                  fontSize: 16, // consistent with PaymentDetails button
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
