import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minimalecom/components/my_signin.dart';
import 'package:minimalecom/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); 

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String errorMessage = '';

  // Async sign-up method
  Future<void> signUserUp() async {
    // 1) Check matching passwords
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      setState(() => errorMessage = 'Passwords do not match');
      return;
    }

    try {
      // 2) Attempt to create user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 3) Check if widget is still in the tree
      if (!mounted) return;

      // 4) Navigate to MeasurementsPage instead of ShopPage
      
      Navigator.pushReplacementNamed(context, '/measurements_page');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() => errorMessage = 'Email is already in use');
      } else if (e.code == 'weak-password') {
        setState(() => errorMessage = 'Password is too weak');
      } else {
        setState(() => errorMessage = 'Something went wrong: ${e.message}');
      }
    } catch (e) {
      setState(() => errorMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.cases_sharp, size: 100),
              const SizedBox(height: 50),
              Text(
                "Create a new account",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              
              const SizedBox(height: 15),
             
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              
              const SizedBox(height: 15),
              
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 25),
              if (errorMessage.isNotEmpty) ...[
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              MySignin(onTap: signUserUp),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[400]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[400]),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Already have an account? Login now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login_page');
                    },
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
