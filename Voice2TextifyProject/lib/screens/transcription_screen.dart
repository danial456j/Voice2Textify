import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Speech-to-text package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore for storing data

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final SpeechToText _speechToText = SpeechToText(); // Speech-to-Text instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  bool _speechEnabled = false; // Flag to check if speech recognition is enabled
  bool _isListening = false; // Flag to check if the app is currently listening
  String _currentTranscription =
      ''; // Holds the latest segment of transcription
  String _transcriptionBuffer = ''; // Accumulates all transcriptions
  String transcribedText = ''; // Complete transcription displayed on screen
  late TextEditingController _textController; // Controller for live updates
  String? _sessionId; // Unique ID for the transcription session
  double _textSize = 16.0; // Font size for transcription display

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(); // Initialize TextField controller
    _initializeSpeech(); // Initialize speech-to-text functionality
    _startSession(); // Start a new transcription session
  }

  @override
  void dispose() {
    _textController.dispose(); // Dispose the TextField controller
    _endSession(); // End the transcription session
    super.dispose();
  }

  /// Initialize Speech-to-Text functionality
  void _initializeSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          _appendToBuffer(); // Save transcription to buffer when paused
        }
      },
      onError: (error) => print("SpeechToText Error: $error"), // Handle errors
    );
    setState(() {});
  }

  /// Start a transcription session in Firestore
  Future<void> _startSession() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final sessionRef = _firestore.collection('sessions').doc();
      _sessionId = sessionRef.id; // Generate session ID

      // Save session data in Firestore
      await sessionRef.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': null,
        'transcriptions': [],
      });
      print("Session started: $_sessionId");
    }
  }

  /// End the transcription session and save data to Firestore
  Future<void> _endSession() async {
    if (_sessionId != null) {
      _appendToBuffer(); // Append any remaining transcription
      await _saveFinalTranscription(); // Save final transcription to Firestore
      await _firestore.collection('sessions').doc(_sessionId).update({
        'completedAt':
            FieldValue.serverTimestamp(), // Mark session as completed
      });
      print("Session completed: $_sessionId");
    }
  }

  /// Append the current transcription to the buffer
  void _appendToBuffer() {
    if (_currentTranscription.isNotEmpty) {
      setState(() {
        _transcriptionBuffer +=
            (_transcriptionBuffer.isEmpty ? '' : '\n') + _currentTranscription;
        transcribedText = _transcriptionBuffer; // Update displayed text
        _currentTranscription = ''; // Clear current transcription
        _textController.text = transcribedText; // Update TextField
      });
      print("Buffer updated: $_transcriptionBuffer");
    }
  }

  /// Save the final transcription to Firestore
  Future<void> _saveFinalTranscription() async {
    if (_sessionId != null && transcribedText.isNotEmpty) {
      await _firestore.collection('sessions').doc(_sessionId).update({
        'transcriptions': FieldValue.arrayUnion([transcribedText]), // Save data
      });
      print("Final transcription saved: $transcribedText");
      _showMessage("Transcription saved!"); // Notify user
    } else {
      _showMessage("No transcription to save."); // Notify if no data
    }
  }

  /// Start listening for speech input
  void _startListening() async {
    if (!_speechEnabled) {
      _showMessage('Speech recognition is not available.');
      return;
    }

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _currentTranscription = result.recognizedWords; // Update current text
          transcribedText =
              _transcriptionBuffer + _currentTranscription; // Combine text
          _textController.text = transcribedText; // Update TextField
        });
      },
      listenFor: const Duration(minutes: 1), // Set max listening time
      pauseFor: const Duration(seconds: 3), // Pause between phrases
      partialResults: true, // Enable partial results
    );
    setState(() {
      _isListening = true; // Update listening state
    });
  }

  /// Stop listening for speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false; // Update listening state
    });
    _appendToBuffer(); // Save data when stopping manually
  }

  /// Toggle between listening and stopping
  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  /// Clear all transcription text
  void _clearText() {
    setState(() {
      _currentTranscription = '';
      _transcriptionBuffer = '';
      transcribedText = '';
      _textController.text = transcribedText; // Update TextField
    });
    _showMessage("Transcription cleared."); // Notify user
  }

  /// Increase transcription text size
  void _increaseTextSize() {
    setState(() {
      _textSize += 2.0; // Increment font size
    });
  }

  /// Decrease transcription text size
  void _decreaseTextSize() {
    setState(() {
      if (_textSize > 10.0) {
        _textSize -= 2.0; // Decrement font size
      }
    });
  }

  /// Show a message using Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Display duration
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice2Textify - Transcribe'), // Title for AppBar
        backgroundColor: Colors.blue, // Background color for AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding for TextField
              child: Column(
                children: [
                  const Text(
                    'Transcription', // Section title
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20), // Add spacing
                  Expanded(
                    child: TextField(
                      maxLines: null, // Allow multi-line input
                      controller: _textController, // Controlled TextField
                      decoration: const InputDecoration(
                        labelText:
                            'Your transcriptions will appear here.', // Placeholder
                        border: OutlineInputBorder(),
                      ),
                      style:
                          TextStyle(fontSize: _textSize), // Dynamic font size
                      readOnly: true, // Prevent editing
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.blue, // Footer background color
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Distribute buttons
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear,
                          color: Colors.white), // Clear button
                      onPressed: _clearText,
                    ),
                    const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListening
                            ? Icons.pause
                            : Icons.mic, // Mic or pause icon
                        color: Colors.white,
                      ),
                      onPressed: _toggleListening, // Toggle listening state
                    ),
                    Text(
                      _isListening ? 'Pause' : 'Mic',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save,
                          color: Colors.white), // Save button
                      onPressed: _saveFinalTranscription,
                    ),
                    const Text(
                      'Save',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
