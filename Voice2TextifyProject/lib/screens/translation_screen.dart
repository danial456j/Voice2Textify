import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; // Import the speech-to-text library
import '../assets/translation_api.dart'; // Import the TranslationApi class for translation functionality

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final SpeechToText _speechToText =
      SpeechToText(); // Instance for speech-to-text functionality
  bool _isListening = false; // Flag to check if the app is actively listening
  String _transcribedText = ''; // Stores the transcribed text
  String _translatedText = ''; // Stores the translated text
  String _targetLanguage =
      'ar'; // Default target language: Arabic ('ar' for Arabic, 'he' for Hebrew)
  double _textSize = 16.0; // Default text size for displayed text

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText(); // Initialize the speech-to-text functionality
  }

  /// Initialize the speech-to-text service
  void _initializeSpeechToText() async {
    await _speechToText.initialize(
        onStatus: _onSpeechStatus); // Set up status listener
    setState(() {}); // Update UI state
  }

  /// Handle speech-to-text status updates
  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false; // Update listening state
      });
    }
  }

  /// Toggle between listening and not listening states
  void _toggleListening() async {
    if (_isListening) {
      // Stop listening
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      // Start listening and update transcribed text
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords; // Capture recognized words
        });
      });
      setState(() {
        _isListening = true;
      });
    }
  }

  /// Translate the transcribed text into the selected language
  Future<void> _translateText() async {
    try {
      // Call the translation API to translate the text
      final translated = await TranslationApi.translate(
        _transcribedText,
        _targetLanguage,
      );
      setState(() {
        _translatedText = translated; // Update translated text
      });
    } catch (e) {
      // Handle errors during translation
      setState(() {
        _translatedText = 'Error translating text: $e';
      });
    }
  }

  /// Increase the font size of the displayed text
  void _increaseTextSize() {
    setState(() {
      _textSize += 2.0; // Increment font size
    });
  }

  /// Decrease the font size of the displayed text
  void _decreaseTextSize() {
    setState(() {
      if (_textSize > 10.0) {
        _textSize -= 2.0; // Decrement font size
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice2Textify - Translate'), // App bar title
        backgroundColor: Colors.blue, // App bar background color
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding around the content
              child: Column(
                children: [
                  // Dropdown for selecting the target language
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Translate to:', // Label for the dropdown
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _targetLanguage,
                        items: [
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text('Arabic'), // Arabic option
                          ),
                          DropdownMenuItem(
                            value: 'he',
                            child: Text('Hebrew'), // Hebrew option
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _targetLanguage =
                                value!; // Update selected language
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TextField for displaying transcribed text
                  TextField(
                    maxLines: 4, // Allow multiple lines
                    controller: TextEditingController(text: _transcribedText),
                    decoration: const InputDecoration(
                      labelText: 'Transcribed Text', // Label for the text field
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _transcribedText = value; // Update transcribed text
                    },
                    style: TextStyle(fontSize: _textSize), // Font size
                  ),
                  const SizedBox(height: 20),

                  // Button to trigger translation
                  ElevatedButton(
                    onPressed: _translateText,
                    child: const Text('Translate'), // Button text
                  ),
                  const SizedBox(height: 20),

                  // Display the translated text
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue), // Border styling
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _translatedText.isEmpty
                          ? 'Translation will appear here.' // Placeholder
                          : _translatedText, // Display translated text
                      style: TextStyle(fontSize: _textSize),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom row of control buttons
          Container(
            color: Colors.blue, // Background color
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Distribute buttons evenly
              children: [
                // Clear button
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _transcribedText = ''; // Clear transcribed text
                      _translatedText = ''; // Clear translated text
                    });
                  },
                  tooltip: 'Clear', // Tooltip for accessibility
                ),
                // Microphone toggle button
                IconButton(
                  icon: Icon(
                    _isListening
                        ? Icons.pause
                        : Icons.mic, // Change icon based on state
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _toggleListening, // Toggle listening
                  tooltip: _isListening ? 'Pause' : 'Start Listening',
                ),
                // Increase text size button
                IconButton(
                  icon: const Icon(Icons.text_increase, color: Colors.white),
                  onPressed: _increaseTextSize, // Increase font size
                  tooltip: 'Increase Text Size',
                ),
                // Decrease text size button
                IconButton(
                  icon: const Icon(Icons.text_decrease, color: Colors.white),
                  onPressed: _decreaseTextSize, // Decrease font size
                  tooltip: 'Decrease Text Size',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
