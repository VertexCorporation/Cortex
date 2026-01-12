# scripts/translate.py

import sys
import os
import html
import requests

# 1. Check for API Key in environment variables
api_key = os.environ.get('GOOGLE_API_KEY')
if not api_key:
    sys.stderr.write("Error: GOOGLE_API_KEY environment variable not set.")
    sys.exit(1)

# 2. Validate Command Line Arguments
if len(sys.argv) < 4:
    sys.stderr.write("Usage: python translate.py <source_lang> <target_lang> \"<text>\"")
    sys.exit(1)

source_lang = sys.argv[1]
target_lang = sys.argv[2]
text_to_translate = sys.argv[3]

# 3. Setup Request URL (Google Translate v2 REST API)
url = "https://translation.googleapis.com/language/translate/v2"

# 4. Configure Parameters
# Note: 'format': 'text' tells Google to return plain text rather than HTML-encoded text
# (e.g., returning "'" instead of "&#39;"), which simplifies processing in Dart.
params = {
    'q': text_to_translate,
    'source': source_lang,
    'target': target_lang,
    'key': api_key,
    'format': 'text'
}

try:
    # 5. Execute Request
    response = requests.post(url, data=params)
    response.raise_for_status()  # Automatically raises an exception for 4xx/5xx errors

    # 6. Parse JSON Response
    result = response.json()
    translated_text = result['data']['translations'][0]['translatedText']

    # 7. Decode HTML Entities
    # Even with format='text', using html.unescape ensures all special characters
    # (like &amp;, &gt;, &quot;) are converted back to their true symbols correctly.
    clean_text = html.unescape(translated_text)

    # 8. Output Result
    # print with end='' prevents adding an extra newline character,
    # keeping the string clean for the Dart script.
    print(clean_text, end='')

except Exception as e:
    # Output the specific error message to stderr so the Dart script knows it failed.
    sys.stderr.write(f"Translation API Error: {str(e)}")
    sys.exit(1)