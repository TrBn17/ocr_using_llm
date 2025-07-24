import os
import sys

# Add the app directory to the Python path
app_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app")
sys.path.insert(0, app_dir)

# Change to the app directory so relative paths work correctly
os.chdir(app_dir)

# Import and run the main extract function
from app.simple_extract import main

if __name__ == "__main__":
    print("🚀 Launching ID Card Extractor v2 (Append Mode)...")
    print("Template location: form/Input Form_Tmp.docx")
    print("Data location: data/")
    print("Mode: Append new entries to existing form")
    print("-" * 50)
    main()
