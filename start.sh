
# Exit on error
set -e

echo "Starting Flask application..."

# Check if Python is available
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    echo "ERROR: Python not found"
    exit 1
fi

# Check if pip is installed and install dependencies
if $PYTHON_CMD -m pip --version &>/dev/null; then
    echo "Installing dependencies..."
    $PYTHON_CMD -m pip install -r requirements.txt
else
    echo "WARNING: pip not found, skipping dependency installation"
fi

# Try to run with Flask command
if command -v flask &>/dev/null; then
    echo "Starting with flask command..."
    flask run --host=0.0.0.0 --port=${PORT:-5000}
else
    # Fallback to running with Python directly
    echo "Flask command not found, starting with Python directly..."
    $PYTHON_CMD app.py
fi
