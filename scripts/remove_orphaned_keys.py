# scripts/remove_orphaned_keys.py

import os
import json

def clean_orphaned_keys():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    arb_dir = os.path.join(project_root, 'lib', 'l10n')
    source_arb_file = os.path.join(arb_dir, 'app_en.arb')
    
    with open(source_arb_file, 'r', encoding='utf-8') as f:
        source_json = json.load(f)
        
    source_keys = set(source_json.keys())
    
    for file_name in os.listdir(arb_dir):
        if file_name.endswith('.arb') and file_name != 'app_en.arb':
            file_path = os.path.join(arb_dir, file_name)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    target_json = json.load(f)
                
                # Filter keys that are in source_keys or are special @@locale metadata
                cleaned_json = {}
                removed_count = 0
                for key, val in target_json.items():
                    if key in source_keys or key == '@@locale':
                        cleaned_json[key] = val
                    else:
                        removed_count += 1
                        
                if removed_count > 0:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        json.dump(cleaned_json, f, ensure_ascii=False, indent=2)
                    print(f"Removed {removed_count} orphaned keys from {file_name}")
            except Exception as e:
                print(f"Error cleaning {file_name}: {e}")

if __name__ == '__main__':
    clean_orphaned_keys()
