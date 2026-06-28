# scripts/fix_corrupted_keys.py

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

TARGET_LOCALES = [
    'tr', 'zh', 'fr', 'hi', 'pt', 'id', 'az', 'de', 'es', 'it', 'ja', 'ko', 'ru', 'ar', 'nl'
]

FREE_URL = "https://translate.googleapis.com/translate_a/single"

def translate_text_free(text, source_lang, target_lang):
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
        headers={'User-Agent': 'Mozilla/5.0'}
    )
    
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode('utf-8'))
        translated_parts = [part[0] for part in data[0] if part[0]]
        return "".join(translated_parts)

def protect_placeholders(text):
    placeholders = re.findall(r'\{[a-zA-Z0-9_]+\}', text)
    protected_text = text
    mappings = {}
    for i, ph in enumerate(placeholders):
        token = f"[PH_{i}]"
        mappings[token] = ph
        protected_text = protected_text.replace(ph, token)
    return protected_text, mappings

def restore_placeholders(text, mappings):
    restored_text = text
    restored_text = re.sub(r'\[\s*PH\s*_\s*(\d+)\s*\]', r'[PH_\1]', restored_text)
    for token, original in mappings.items():
        restored_text = restored_text.replace(token, original)
    return restored_text

def clean_translated_text(text):
    return (text.replace('&#39;', "'")
                .replace('&quot;', '"')
                .replace('&amp;', '&')
                .replace('&lt;', '<')
                .replace('&gt;', '>')
                .replace('«', '"')
                .replace('»', '"'))

def translate_batch(batch_items, source_lang, target_lang):
    if not batch_items:
        return []
    
    protected_items = []
    batch_mappings = []
    for item in batch_items:
        protected, mappings = protect_placeholders(item)
        protected_items.append(protected)
        batch_mappings.append(mappings)
    
    separator = " ||| "
    combined_text = separator.join(protected_items)
    
    try:
        translated_combined = translate_text_free(combined_text, source_lang, target_lang)
        split_pattern = r'\s*\|\|\|\s*'
        translated_parts = re.split(split_pattern, translated_combined.strip())
        translated_parts = [clean_translated_text(part.strip()) for part in translated_parts if part.strip()]
        
        if len(translated_parts) == len(batch_items):
            final_items = []
            for i, part in enumerate(translated_parts):
                restored = restore_placeholders(part, batch_mappings[i])
                final_items.append(restored)
            return final_items
        else:
            print(f"Batch size mismatch ({len(translated_parts)} vs {len(batch_items)}). Falling back to key-by-key.")
    except Exception as e:
        print(f"Batch failed: {e}. Falling back to key-by-key.")
        
    final_items = []
    for item in batch_items:
        try:
            protected, mappings = protect_placeholders(item)
            trans = translate_text_free(protected, source_lang, target_lang)
            cleaned = clean_translated_text(trans)
            restored = restore_placeholders(cleaned, mappings)
            final_items.append(restored)
            time.sleep(0.3)
        except Exception as e:
            final_items.append(item)
    return final_items

def main():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    arb_dir = os.path.join(project_root, 'lib', 'l10n')
    source_arb_file = os.path.join(arb_dir, 'app_en.arb')
    
    with open(source_arb_file, 'r', encoding='utf-8') as f:
        source_json = json.load(f)
        
    source_keys = {k: v for k, v in source_json.items() if not k.startswith('@') and k != '@@locale'}
    
    for locale in TARGET_LOCALES:
        if locale == 'en':
            continue
        
        target_file_name = f"app_{locale}.arb"
        target_file_path = os.path.join(arb_dir, target_file_name)
        
        if not os.path.exists(target_file_path):
            continue
            
        with open(target_file_path, 'r', encoding='utf-8') as f:
            target_json = json.load(f)
            
        keys_to_fix = []
        texts_to_translate = []
        
        for key, value in target_json.items():
            if isinstance(value, str) and '\ufffd' in value:
                if key in source_keys:
                    keys_to_fix.append(key)
                    texts_to_translate.append(source_keys[key])
                    
        if not keys_to_fix:
            print(f"No corrupted keys found for {locale}")
            continue
            
        print(f"Surgically fixing {len(keys_to_fix)} corrupted keys for {locale}...")
        
        batch_size = 30
        fixed_results = []
        
        for i in range(0, len(texts_to_translate), batch_size):
            batch_texts = texts_to_translate[i:i+batch_size]
            translated_batch = translate_batch(batch_texts, 'en', locale)
            fixed_results.extend(translated_batch)
            time.sleep(0.5)
            
        for key, fixed_val in zip(keys_to_fix, fixed_results):
            target_json[key] = fixed_val
            
        with open(target_file_path, 'w', encoding='utf-8') as f:
            json.dump(target_json, f, ensure_ascii=False, indent=2)
            
        print(f"Successfully fixed and saved {target_file_name}")

if __name__ == '__main__':
    main()
