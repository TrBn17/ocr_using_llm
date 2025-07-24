"""Basic tests for the OCR ID Card Extractor."""
import os
import sys
import pytest

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

def test_imports():
    """Test that main modules can be imported."""
    try:
        from app.simple_extract import sanitize_filename, docx_replace
        assert callable(sanitize_filename)
        assert callable(docx_replace)
    except ImportError:
        # Skip if dependencies not available in CI
        pytest.skip("Dependencies not available")

def test_sanitize_filename():
    """Test filename sanitization function."""
    try:
        from app.simple_extract import sanitize_filename
        
        # Test basic functionality
        assert sanitize_filename("test:file") == "testfile"
        assert sanitize_filename("test<>file") == "testfile"
        assert sanitize_filename("normal_file") == "normal_file"
        assert sanitize_filename("test/\\*?file") == "testfile"
        assert sanitize_filename("") == ""
    except ImportError:
        pytest.skip("Dependencies not available")

def test_config_import():
    """Test that config can be imported."""
    try:
        from infra.config import GEMINI_API_KEY
        # We don't test the actual value since it's a secret
        assert isinstance(GEMINI_API_KEY, (str, type(None)))
    except ImportError:
        pytest.skip("Config not available")

def test_file_structure():
    """Test that required files exist."""
    base_path = os.path.join(os.path.dirname(__file__), '..', 'src')
    
    required_files = [
        'app/simple_extract.py',
        'infra/config.py',
        'requirements.txt'
    ]
    
    for file_path in required_files:
        full_path = os.path.join(base_path, file_path)
        assert os.path.exists(full_path), f"Required file missing: {file_path}"

def test_requirements_file():
    """Test that requirements.txt has expected dependencies."""
    req_path = os.path.join(os.path.dirname(__file__), '..', 'src', 'requirements.txt')
    
    if os.path.exists(req_path):
        with open(req_path, 'r') as f:
            content = f.read()
            
        expected_deps = [
            'google-generativeai',
            'Pillow',
            'python-docx'
        ]
        
        for dep in expected_deps:
            assert dep in content, f"Missing dependency: {dep}"
