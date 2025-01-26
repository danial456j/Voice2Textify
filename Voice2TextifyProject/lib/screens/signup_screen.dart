import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for storing user data

// Main Sign Up screen widget
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for validating the form
  final _nameController = TextEditingController(); // Controller for name input
  final _emailController =
      TextEditingController(); // Controller for email input
  final _passwordController =
      TextEditingController(); // Controller for password input
  final _confirmPasswordController =
      TextEditingController(); // Controller for confirming password

  bool _isLoading = false; // Flag to indicate loading during sign-up process

  // Function to handle user sign-up
  void _signUp() async {
    // Validate the form fields
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator while processing
      });

      try {
        // Create a new user in Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users') // 'users' collection in Firestore
            .doc(userCredential.user!.uid) // Document ID is the user's UID
            .set({
          'name': _nameController.text, // Store the user's name
          'email': _emailController.text, // Store the user's email
          'createdAt': DateTime.now(), // Timestamp of account creation
        });

        // Show success message upon account creation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        // Navigate back to the previous screen (e.g., LoginScreen)
        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        // Handle specific Firebase Authentication errors
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password is too weak.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }

        // Show error message in a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        // Handle any other errors
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'), // Title for the AppBar
        backgroundColor: Colors.blue, // Background color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey, // Assign the form key for validation
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the form
            children: [
              // Logo and Title
              const Column(
                children: [
                  Icon(
                    Icons.account_circle, // User account icon
                    size: 80, // Icon size
                    color: Colors.blue, // Icon color
                  ),
                  Text(
                    'Create Your Account', // Screen title
                    style: TextStyle(
                      fontSize: 28, // Font size
                      fontWeight: FontWeight.bold, // Bold text
                      color: Colors.blue, // Text color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30), // Add spacing

              // Full Name Field
              TextFormField(
                controller: _nameController, // Controller for name input
                decoration: InputDecoration(
                  labelText: 'Enter Your Full Name', // Label for the field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                validator: (value) {
                  // Validate the name field
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15), // Add spacing

              // Email Field
              TextFormField(
                controller: _emailController, // Controller for email input
                decoration: InputDecoration(
                  labelText: 'Enter Your Email Address', // Label for the field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                keyboardType: TextInputType.emailAddress, // Keyboard type
                validator: (value) {
                  // Validate the email field
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15), // Add spacing

              // Password Field
              TextFormField(
                controller:
                    _passwordController, // Controller for password input
                decoration: InputDecoration(
                  labelText: 'Enter Your Password', // Label for the field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                obscureText: true, // Hide the password input
                validator: (value) {
                  // Validate the password field
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15), // Add spacing

              // Confirm Password Field
              TextFormField(
                controller:
                    _confirmPasswordController, // Controller for confirmation input
                decoration: InputDecoration(
                  labelText: 'Confirm Your Password', // Label for the field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                obscureText: true, // Hide the password input
                validator: (value) {
                  // Validate that passwords match
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Add spacing

              // Sign Up Button
              _isLoading
                  ? const CircularProgressIndicator() // Show loader if signing up
                  : ElevatedButton(
                      onPressed: _signUp, // Call the sign-up function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15), // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                      ),
                      child: const Text(
                        'Sign Up', // Button text
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
