# scripts/translate_batch.py

import os
import json
import urllib.request
import urllib.parse
import re
import sys
import time

# Ensure stdout uses UTF-8 to prevent encoding errors on Windows console
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

# Target locales to support (45 target locales)
TARGET_LOCALES = [
    'tr', 'zh', 'fr', 'hi', 'pt', 'id', 'az', 'de', 'es', 'it', 'ja', 'ko', 'ru', 'ar', 'nl'
]

# Google Translate free endpoint
FREE_URL = "https://translate.googleapis.com/translate_a/single"

def translate_text_free(text, source_lang, target_lang):
    """Translates text using Google's free translation web API."""
    params = {
        "client": "gtx",
        "sl": source_lang,
        "tl": target_lang,
        "dt": "t",
        "q": text
    }
    query_string = urllib.parse.urlencode(params)
    full_url = f"{FREE_URL}?{query_string}"
    
    req = urllib.request.Request(
        full_url, 
        headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
    )
    
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        translated_parts = [part[0] for part in data[0] if part[0]]
        return "".join(translated_parts)

def translate_via_api(text, source_lang, target_lang, api_key):
    """Translates text using Google Translate v2 REST API (paid)."""
    url = "https://translation.googleapis.com/language/translate/v2"
    params = {
        'q': text,
        'source': source_lang,
        'target': target_lang,
        'key': api_key,
        'format': 'text'
    }
    data = urllib.parse.urlencode(params).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    with urllib.request.urlopen(req) as response:
        result = json.loads(response.read().decode('utf-8'))
        return result['data']['translations'][0]['translatedText']

def translate_single(text, source_lang, target_lang, api_key=None):
    """Wrapper that tries paid API first, falls back to free API on failure/absence."""
    if api_key:
        try:
            return translate_via_api(text, source_lang, target_lang, api_key)
        except Exception as e:
            sys.stderr.write(f"Paid API failed, falling back to free: {e}\n")
    return translate_text_free(text, source_lang, target_lang)

def protect_placeholders(text):
    """Replaces Flutter placeholders {name} with [PH_X] tokens to protect them during translation."""
    placeholders = re.findall(r'\{[a-zA-Z0-9_]+\}', text)
    protected_text = text
    mappings = {}
    for i, ph in enumerate(placeholders):
        token = f"[PH_{i}]"
        mappings[token] = ph
        protected_text = protected_text.replace(ph, token)
    return protected_text, mappings

def restore_placeholders(text, mappings):
    """Restores protected [PH_X] tokens back to original Flutter placeholders {name}."""
    restored_text = text
    # Handle cases where translation might introduce spaces inside our placeholder tokens
    # e.g., "[PH_0]" -> "[PH _ 0]" or similar
    restored_text = re.sub(r'\[\s*PH\s*_\s*(\d+)\s*\]', r'[PH_\1]', restored_text)
    for token, original in mappings.items():
        restored_text = restored_text.replace(token, original)
    return restored_text

def clean_translated_text(text):
    """Cleans up common HTML entities or translation artifacts."""
    return (text.replace('&#39;', "'")
                .replace('&quot;', '"')
                .replace('&amp;', '&')
                .replace('&lt;', '<')
                .replace('&gt;', '>')
                .replace('«', '"')
                .replace('»', '"'))

def translate_batch(batch_items, source_lang, target_lang, api_key=None):
    """Translates a batch of strings, protecting placeholders, and handling failures."""
    if not batch_items:
        return []
    
    # 1. Protect placeholders and prepare text
    protected_items = []
    batch_mappings = []
    for item in batch_items:
        protected, mappings = protect_placeholders(item)
        protected_items.append(protected)
        batch_mappings.append(mappings)
    
    # We join strings using a unique separator
    separator = " ||| "
    combined_text = separator.join(protected_items)
    
    try:
        # Translate combined text
        translated_combined = translate_single(combined_text, source_lang, target_lang, api_key)
        
        # Split back
        # Google Translate sometimes returns variation of separators, e.g. with spaces
        # We use regex to split flexibly
        split_pattern = r'\s*\|\|\|\s*'
        translated_parts = re.split(split_pattern, translated_combined.strip())
        
        # Clean segments and filter out empty ones (e.g. from trailing separators)
        translated_parts = [clean_translated_text(part.strip()) for part in translated_parts if part.strip()]
        
        # If segments count matches, restore placeholders and return
        if len(translated_parts) == len(batch_items):
            final_items = []
            for i, part in enumerate(translated_parts):
                restored = restore_placeholders(part, batch_mappings[i])
                final_items.append(restored)
            return final_items
        else:
            sys.stderr.write(f"Batch size mismatch ({len(translated_parts)} vs {len(batch_items)}) for {target_lang}. Falling back to key-by-key translation.\n")
    except Exception as e:
        sys.stderr.write(f"Batch translation failed: {e}. Falling back to key-by-key translation.\n")
    
    # Fallback: Translate key-by-key
    final_items = []
    for i, item in enumerate(batch_items):
        try:
            protected, mappings = protect_placeholders(item)
            trans = translate_single(protected, source_lang, target_lang, api_key)
            cleaned = clean_translated_text(trans)
            restored = restore_placeholders(cleaned, mappings)
            final_items.append(restored)
            time.sleep(0.5) # small delay to avoid hitting rate limits
        except Exception as e:
            sys.stderr.write(f"Failed to translate: '{item}' -> using source: {e}\n")
            final_items.append(item)
    return final_items

def main():
    # Setup paths
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    arb_dir = os.path.join(project_root, 'lib', 'l10n')
    source_arb_file = os.path.join(arb_dir, 'app_en.arb')
    
    if not os.path.exists(source_arb_file):
        sys.stderr.write(f"Source file not found: {source_arb_file}\n")
        sys.exit(1)
        
    with open(source_arb_file, 'r', encoding='utf-8') as f:
        source_json = json.load(f)
        
    source_keys = {k: v for k, v in source_json.items() if not k.startswith('@') and k != '@@locale'}
    
    # Get API key if available
    api_key = os.environ.get('GOOGLE_API_KEY')
    
    print(f"Loaded {len(source_keys)} keys from template (app_en.arb)")
    
    # Loop over all target locales
    for locale in TARGET_LOCALES:
        print(f"\n--- Processing locale: {locale} ---")
        target_file_name = f"app_{locale}.arb"
        target_file_path = os.path.join(arb_dir, target_file_name)
        
        target_json = {}
        if os.path.exists(target_file_path):
            try:
                with open(target_file_path, 'r', encoding='utf-8') as f:
                    target_json = json.load(f)
            except Exception as e:
                print(f"Warning: Could not parse {target_file_name}, treating as empty. Error: {e}")
                
        # Reset locale key
        target_json['@@locale'] = locale
        
        # Find which keys are missing or empty
        keys_to_translate = []
        texts_to_translate = []
        
        for key, value in source_keys.items():
            # If target lacks the key, or if the key is empty, or if we want to force translate (optional)
            if key not in target_json or not target_json[key]:
                keys_to_translate.append(key)
                texts_to_translate.append(value)
                
        if not keys_to_translate:
            print(f"All keys are up to date for {locale}")
            continue
            
        print(f"Found {len(keys_to_translate)} keys to translate for {locale}")
        
        # Batch translation (groups of 30 keys)
        batch_size = 30
        translated_results = []
        
        for i in range(0, len(texts_to_translate), batch_size):
            batch_texts = texts_to_translate[i:i+batch_size]
            print(f"Translating batch {i//batch_size + 1} of {(len(texts_to_translate)-1)//batch_size + 1}...")
            
            translated_batch = translate_batch(batch_texts, 'en', locale, api_key)
            translated_results.extend(translated_batch)
            
            # Sleep 1 second between batches to respect rate limits
            time.sleep(1.0)
            
        # Write back to target_json
        for key, trans in zip(keys_to_translate, translated_results):
            target_json[key] = trans
            
        # Save updated file
        with open(target_file_path, 'w', encoding='utf-8') as f:
            json.dump(target_json, f, ensure_ascii=False, indent=2)
            
        print(f"Saved: {target_file_name}")

if __name__ == '__main__':
    main()
