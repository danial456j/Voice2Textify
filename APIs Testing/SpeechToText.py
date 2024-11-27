#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov 24 12:28:35 2024

@author: danialjarrous
"""

from google.cloud import speech
from google.cloud import translate_v2 as translate
from google.cloud import language_v1


client = speech.SpeechClient.from_service_account_file('key.json')
translate_client = translate.Client.from_service_account_json('key.json')
language_client = language_v1.LanguageServiceClient.from_service_account_file('key.json')


file_name = "speechTest.mp3"


with open(file_name, 'rb') as f:
    mp3_data = f.read()
    

audio_file = speech.RecognitionAudio(content=mp3_data)


config = speech.RecognitionConfig(
    
    sample_rate_hertz=44100,
    enable_automatic_punctuation=True,
    language_code='en-US'
)


response = client.recognize(
    config=config,
    audio=audio_file
    
    )

print(response)


# Get the transcribed text
transcription = ""
for result in response.results:
    transcription += result.alternatives[0].transcript

print("Transcription:", transcription)

# Step 2: Translate Transcription
target_language = "ar"  # e.g., English
translation = translate_client.translate(transcription, target_language=target_language)

print("Translation:", translation["translatedText"])



# Step 3: Summarize the original transcription
def summarize_text(text, max_sentences=1):
    """Summarizes the given text using Google Cloud Natural Language API."""
    document = language_v1.Document(content=text, type_=language_v1.Document.Type.PLAIN_TEXT)
    
    # Analyze the text
    response = language_client.analyze_entities(document=document)
    sentences = language_client.analyze_syntax(document=document).sentences
    
    # Extract entity salience scores
    entity_scores = {entity.name: entity.salience for entity in response.entities}
    
    # Rank sentences by their relevance to important entities
    sentence_scores = []
    for sentence in sentences:
        score = 0
        for entity in response.entities:
            if entity.name in sentence.text.content:
                score += entity.salience
        sentence_scores.append((sentence.text.content, score))
    
    # Sort sentences by score and select the top ones
    sorted_sentences = sorted(sentence_scores, key=lambda x: x[1], reverse=True)
    summary = " ".join([s[0] for s in sorted_sentences[:max_sentences]])
    
    return summary

# Summarize the original transcription
original_summary = summarize_text(transcription)
print("Original Summary:", original_summary)



"In a small forgetting Village stood. An ancient tree known as the whispering tree Legends claimed."
"It could speak sharing Secrets only with those brave enough to listen."

"In a small, forgotten village stood an ancient tree known as the Whispering Tree. Legends claimed "
"it could speak, sharing secrets only with those brave enough to listen."