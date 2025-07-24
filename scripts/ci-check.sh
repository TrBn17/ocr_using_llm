#!/bin/bash
# Script to run CI/CD checks locally before pushing

echo "🔍 Running local CI/CD checks..."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2 passed${NC}"
    else
        echo -e "${RED}❌ $2 failed${NC}"
        exit 1
    fi
}

# Check if we're in the right directory
if [ ! -f "src/requirements.txt" ]; then
    echo -e "${RED}❌ Please run this script from the project root directory${NC}"
    exit 1
fi

echo "📦 Installing dependencies..."
cd src
pip install -r requirements.txt
pip install flake8 black isort pytest pytest-cov bandit safety
cd ..

echo -e "\n${YELLOW}1. Running linting checks...${NC}"

echo "🔍 Flake8 syntax check..."
flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
print_status $? "Flake8 syntax check"

echo "🔍 Flake8 full check..."
flake8 src/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
print_status $? "Flake8 full check"

echo "🎨 Black formatting check..."
black --check src/
print_status $? "Black formatting"

echo "📚 Import sorting check..."
isort --check-only src/
print_status $? "Import sorting"

echo -e "\n${YELLOW}2. Running tests...${NC}"

echo "🧪 Running pytest..."
python -m pytest tests/ -v --tb=short
print_status $? "Tests"

echo "🔧 Basic functionality test..."
cd src
python -c "from app.simple_extract import sanitize_filename; print('✅ Basic import test passed')"
print_status $? "Basic functionality"
cd ..

echo -e "\n${YELLOW}3. Running security checks...${NC}"

echo "🛡️ Bandit security scan..."
bandit -r src/ -f json -o bandit-report.json
print_status $? "Bandit security scan"

echo "🔐 Safety vulnerability check..."
cd src && safety check -r requirements.txt
print_status $? "Safety check"
cd ..

echo -e "\n${GREEN}🎉 All checks passed! Ready to push.${NC}"
