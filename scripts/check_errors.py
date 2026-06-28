import os
import json
import sys

# Ensure stdout uses UTF-8 to prevent encoding errors on Windows console
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')

def check_files():
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    arb_dir = os.path.join(project_root, 'lib', 'l10n')
    
    errors_found = 0
    
    for file_name in os.listdir(arb_dir):
        if file_name.endswith('.arb'):
            file_path = os.path.join(arb_dir, file_name)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                for key, val in data.items():
                    if isinstance(val, str) and '\ufffd' in val:
                        print(f"Error in {file_name}: key '{key}' contains replacement char: {repr(val)}")
                        errors_found += 1
            except Exception as e:
                print(f"JSON syntax error in {file_name}: {e}")
                errors_found += 1
                
    if errors_found == 0:
        print("ALL TESTS PASSED! No corrupted characters or JSON syntax errors found.")
    else:
        print(f"Found {errors_found} errors total.")

if __name__ == '__main__':
    check_files()
