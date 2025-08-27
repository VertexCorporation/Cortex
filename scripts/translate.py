# scripts/translate.py

import sys
import os
from google.cloud import translate_v2 as translate

# Get the API Key from the environment variable set by our bashrc function
api_key = os.environ.get('GOOGLE_API_KEY')
if not api_key:
    sys.stderr.write("Error: GOOGLE_API_KEY environment variable not set.")
    sys.exit(1)

# Get arguments from Dart
if len(sys.argv) < 4:
    sys.stderr.write("Usage: python google_translate.py <source_lang> <target_lang> \"<text>\"")
    sys.exit(1)

source_lang = sys.argv[1]
target_lang = sys.argv[2]
text_to_translate = sys.argv[3]

# Create the client explicitly with our API Key
client = translate.Client(target_language=target_lang, client_options={'api_key': api_key})

# Call the Google Translate API
result = client.translate(
    text_to_translate,
    # target_language is now set during client creation
    source_language=source_lang
)

# Return ONLY the translated text
print(result['translatedText'], end='')