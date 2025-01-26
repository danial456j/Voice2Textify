import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for data handling

// Widget for displaying recent transcriptions
class RecentTranscriptions extends StatelessWidget {
  const RecentTranscriptions({Key? key}) : super(key: key);

  // Method to fetch transcriptions from Firestore
  Future<List<String>> _fetchTranscriptions() async {
    // Get the currently logged-in user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Throw an exception if the user is not logged in
      throw Exception("User not logged in");
    }

    // Query Firestore for transcriptions belonging to the logged-in user
    final snapshot = await FirebaseFirestore.instance
        .collection('sessions') // Collection containing session data
        .where('userId', isEqualTo: user.uid) // Filter by user ID
        .get();

    // Extract and aggregate transcription data from Firestore documents
    List<String> transcriptions = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('transcriptions')) {
        // Check if the document contains a 'transcriptions' field
        final List<dynamic> transcriptionList = data['transcriptions'];
        // Add all transcriptions to the list after converting them to strings
        transcriptions.addAll(transcriptionList.map((e) => e.toString()));
      }
    }

    return transcriptions; // Return the list of transcriptions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Transcriptions'), // App bar title
        backgroundColor: Colors.blue, // App bar background color
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchTranscriptions(), // Fetch transcriptions asynchronously
        builder: (context, snapshot) {
          // Show a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Loading spinner
            );
          }
          // Display an error message if an error occurs
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', // Error message
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }
          // Handle the case where no transcriptions are found
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No transcriptions found.', // No data message
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // Display the list of transcriptions
          else {
            final transcriptions = snapshot.data!;
            return ListView.builder(
              itemCount: transcriptions.length, // Number of transcriptions
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    transcriptions[index], // Display transcription text
                    style: const TextStyle(fontSize: 16),
                  ),
                  leading: const Icon(Icons.description,
                      color: Colors.blue), // Icon for each item
                );
              },
            );
          }
        },
      ),
    );
  }
}
