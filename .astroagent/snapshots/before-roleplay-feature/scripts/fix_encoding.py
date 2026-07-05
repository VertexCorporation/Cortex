# scripts/fix_encoding.py

import os
import json

# CP1252 mapping for 0x80-0x9F
cp1252_to_unicode = {
    0x80: '\u20ac', 0x82: '\u201a', 0x83: '\u0192', 0x84: '\u201e', 0x85: '\u2026',
    0x86: '\u2020', 0x87: '\u2021', 0x88: '\u02c6', 0x89: '\u2030', 0x8a: '\u0160',
    0x8b: '\u2039', 0x8c: '\u0152', 0x8e: '\u017d', 0x91: '\u2018', 0x92: '\u2019',
    0x93: '\u201c', 0x94: '\u201d', 0x95: '\u2022', 0x96: '\u2013', 0x97: '\u2014',
    0x98: '\u02dc', 0x99: '\u2122', 0x9a: '\u0161', 0x9b: '\u203a', 0x9c: '\u0153',
    0x9e: '\u017e', 0x9f: '\u0178'
}
unicode_to_cp1252_byte = {v: k for k, v in cp1252_to_unicode.items()}

# CP1254 (Turkish) mapping overrides for 0x80-0x9F
cp1254_to_unicode = {
    **cp1252_to_unicode,
    0x9f: '\u015f' # small s with cedilla (ş)
}
unicode_to_cp1254_byte = {v: k for k, v in cp1254_to_unicode.items()}

def decode_mojibake(text, unicode_to_byte_map):
    byte_list = []
    for c in text:
        if c in unicode_to_byte_map:
            byte_list.append(unicode_to_byte_map[c])
        elif ord(c) < 256:
            byte_list.append(ord(c))
        else:
            # If it's a character we don't recognize, we keep its unicode code point (might fail during utf-8 decode if not careful)
            # But usually it's just a standard character.
            # Let's convert it to utf-8 bytes and append them
            byte_list.extend(c.encode('utf-8'))
            
    # Convert byte list to bytes object
    byte_data = bytes(byte_list)
    # Decode as UTF-8
    return byte_data.decode('utf-8', errors='replace')

def fix_file(file_path):
    print(f"Fixing: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Let's try CP1252 first, fallback to CP1254
    fixed = decode_mojibake(content, unicode_to_cp1252_byte)
    
    # Check if the output has valid JSON structure
    try:
        json.loads(fixed)
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed)
        print("-> Fixed successfully (CP1252)")
        return True
    except Exception as e:
        # Try CP1254
        try:
            fixed = decode_mojibake(content, unicode_to_cp1254_byte)
            json.loads(fixed)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            print("-> Fixed successfully (CP1254)")
            return True
        except Exception as e2:
            print(f"-> Failed to fix: {e2}")
            return False

def main():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    arb_dir = os.path.join(project_root, 'lib', 'l10n')
    
    # Loop over files in arb_dir
    for file_name in os.listdir(arb_dir):
        if file_name.endswith('.arb') and file_name not in ['app_en.arb', 'app_tr.arb']:
            file_path = os.path.join(arb_dir, file_name)
            fix_file(file_path)

if __name__ == '__main__':
    main()
