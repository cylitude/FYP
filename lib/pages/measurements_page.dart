import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMeasurementPage extends StatefulWidget {
  const BodyMeasurementPage({super.key});

  @override
  State<BodyMeasurementPage> createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _shoulderController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  String _selectedGender = 'Male';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

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

  Color _getLabelColor(String text) {
    return text.trim().isEmpty ? Colors.lightBlue : Colors.black;
  }

  Future<void> _saveAndContinue() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'No logged in user found.';
        });
        return;
      }
      final uid = user.uid;
      final gender = _selectedGender;
      final height = _heightController.text.trim();
      final weight = _weightController.text.trim();
      final chest = _chestController.text.trim();
      final shoulder = _shoulderController.text.trim();
      final waist = _waistController.text.trim();

      if (height.isEmpty || weight.isEmpty) {
        setState(() {
          _errorMessage = 'Please fill in the required fields (Height, Weight).';
        });
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'gender': gender,
        'height': height,
        'weight': weight,
        'chest': chest,
        'shoulder': shoulder,
        'waist': waist,
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/shop_page');
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // New top footnote
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  "Fill in your information to experience a flawless, personalized fit",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Centered BASIC header
              Center(
                child: Text(
                  'BASIC',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              // Centered ADVANCED header
              Center(
                child: Text(
                  'ADVANCED',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Advanced fields are optional to fill in",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
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
