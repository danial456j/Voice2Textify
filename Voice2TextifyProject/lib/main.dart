import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the LoginScreen widget
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core for initialization

void main() async {
  print("Starting main function...");
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter widgets are fully initialized before running the app
  await Firebase.initializeApp(); // Initialize Firebase for the app

  runApp(const MyApp()); // Launch the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: LoginScreen(), // Set LoginScreen as the starting screen of the app
    );
  }
}
