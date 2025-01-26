import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import the login screen for navigation
import 'transcription_screen.dart'; // Import the transcription screen
import 'translation_screen.dart'; // Import the translation screen
import 'recentTranscriptions.dart'; // Import the Recent Transcriptions screen

// Main screen of the app
class HomeScreen extends StatefulWidget {
  final bool isGuest; // Determines if the user is logged in or a guest

  const HomeScreen({super.key, required this.isGuest});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName; // Stores the user's name for personalization
  bool isLoading = true; // Indicates whether the app is fetching data

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _fetchUserName(); // Fetch user's name if logged in
    } else {
      setState(() {
        userName = null; // Set userName to null for guests
        isLoading = false; // No need to fetch data for guests
      });
    }
  }

  // Fetch user name from Firestore for logged-in users
  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(); // Fetch user data from Firestore

        setState(() {
          userName = userDoc['name'] ?? 'User'; // Set name or default to 'User'
          isLoading = false; // Data fetching completed
        });
      }
    } catch (e) {
      print("Error fetching user name: $e"); // Log any errors
      setState(() {
        userName = 'User'; // Fallback name in case of errors
        isLoading = false;
      });
    }
  }

  // Handles login or logout functionality
  void _logoutOrLogin() {
    if (widget.isGuest) {
      // Navigate to LoginScreen if guest
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } else {
      // Log out the user and navigate to LoginScreen
      FirebaseAuth.instance.signOut().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      });
    }
  }

  // Navigate to the Transcription Screen
  void _startTranscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TranscriptionScreen()),
    );
  }

  // Navigate to the Translation Screen
  void _startTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TranslationScreen()),
    );
  }

  // Navigate to Recent Transcriptions Screen
  void _navigateToRecentTranscriptions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecentTranscriptions()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voice2Textify',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // AppBar background color
        leading: const Icon(Icons.account_circle, color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logoutOrLogin(); // Trigger login or logout
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        widget.isGuest ? Icons.login : Icons.logout,
                        color: widget.isGuest ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.isGuest ? 'Log in' : 'Logout'),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.menu, color: Colors.white), // Menu icon
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(), // Show loading spinner
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Content padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Welcome message
                      Center(
                        child: Text(
                          widget.isGuest
                              ? 'Welcome to Voice2Textify!'
                              : 'Welcome back, $userName!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Start Transcription button
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Start Transcription!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _startTranscription, // Navigate on tap
                              child: const Icon(Icons.mic,
                                  size: 80, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Start Translation button
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Start Translation!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _startTranslation, // Navigate on tap
                              child: const Icon(Icons.translate,
                                  size: 80, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Recent Transcriptions (only for logged-in users)
                      if (!widget.isGuest)
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Recent Transcriptions!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _navigateToRecentTranscriptions,
                                child: const Icon(Icons.history,
                                    size: 80, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
