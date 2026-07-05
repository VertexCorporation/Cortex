# scripts/translate.py

import sys
import os
import html
import urllib.request
import urllib.parse
import json

# Ensure stdout uses UTF-8 to prevent encoding errors on Windows console
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

# 1. Validate Command Line Arguments
if len(sys.argv) < 4:
    sys.stderr.write("Usage: python translate.py <source_lang> <target_lang> \"<text>\"")
    sys.exit(1)

source_lang = sys.argv[1]
target_lang = sys.argv[2]
text_to_translate = sys.argv[3]

api_key = os.environ.get('GOOGLE_API_KEY')

def translate_free(text, source, target):
    url = "https://translate.googleapis.com/translate_a/single"
    params = {
        "client": "gtx",
        "sl": source,
        "tl": target,
        "dt": "t",
        "q": text
    }
    query_string = urllib.parse.urlencode(params)
    full_url = f"{url}?{query_string}"
    
    req = urllib.request.Request(
        full_url, 
        headers={'User-Agent': 'Mozilla/5.0'}
    )
    
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        translated_parts = [part[0] for part in data[0] if part[0]]
        return "".join(translated_parts)

def translate_paid(text, source, target, key):
    url = "https://translation.googleapis.com/language/translate/v2"
    params = {
        'q': text,
        'source': source,
        'target': target,
        'key': key,
        'format': 'text'
    }
    data = urllib.parse.urlencode(params).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode('utf-8'))
        return result['data']['translations'][0]['translatedText']

try:
    if api_key:
        try:
            translated_text = translate_paid(text_to_translate, source_lang, target_lang, api_key)
        except Exception as e:
            sys.stderr.write(f"Paid API failed, falling back to free: {e}\n")
            translated_text = translate_free(text_to_translate, source_lang, target_lang)
    else:
        translated_text = translate_free(text_to_translate, source_lang, target_lang)

    # Decode HTML Entities
    clean_text = html.unescape(translated_text)
    print(clean_text, end='')

except Exception as e:
    sys.stderr.write(f"Translation API Error: {str(e)}")
    sys.exit(1)