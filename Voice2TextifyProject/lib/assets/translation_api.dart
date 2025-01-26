import 'dart:convert'; // Provides utilities for JSON encoding and decoding.
import 'package:html_unescape/html_unescape.dart'; // Handles unescaping of HTML entities.
import 'package:http/http.dart' as http; // Used for making HTTP requests.
import '../api/translation_api_key.dart'; // Import the API key from a separate file.
import 'package:translator/translator.dart'; // Import the Google Translator package for translation.

class TranslationApi {
  // Retrieve the API key from the ApiKey class for authentication with Google Translate API.
  static final _apiKey = ApiKey.googleTranslateApiKey;

  // Method to translate a message using the Google Translate API.
  // Takes a message and a target language code as parameters.
  static Future<String> translate(String message, String toLanguageCode) async {
    // Construct the API request URL with the target language, API key, and encoded message.
    final url =
        'https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=${Uri.encodeComponent(message)}';

    // Make a POST request to the Google Translate API.
    final response = await http.post(Uri.parse(url));

    // Check if the response status code indicates success.
    if (response.statusCode == 200) {
      // Parse the response body as JSON.
      final body = json.decode(response.body);

      // Extract the translations from the response data.
      final translations = body['data']['translations'] as List;

      // Get the first translation result.
      final translation = translations.first;

      // Return the translated text after unescaping HTML entities.
      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      // Throw an exception if the request failed, including the error status code.
      throw Exception(
          'Failed to translate text. Error: ${response.statusCode}');
    }
  }

  // Method to translate a message using the Google Translator package.
  // Takes a message, source language code, and target language code as parameters.
  static Future<String> translate2(
      String message, String fromLanguageCode, String toLanguageCode) async {
    // Use the GoogleTranslator package to perform the translation.
    final translation = await GoogleTranslator().translate(
      message, // The message to translate.
      from: fromLanguageCode, // The source language code.
      to: toLanguageCode, // The target language code.
    );

    // Return the translated text.
    return translation.text;
  }
}
