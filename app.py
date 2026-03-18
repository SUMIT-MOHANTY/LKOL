"""Flask application for optional dynamic serving of static content."""

import os
from pathlib import Path

try:
    from flask import Flask, render_template, send_from_directory
    FLASK_AVAILABLE = True
except ImportError:
    FLASK_AVAILABLE = False

def create_app():
    """Create Flask application with proper static handling."""
    if not FLASK_AVAILABLE:
        raise ImportError("Flask not available. Use static serving instead.")

    app = Flask(__name__,
                template_folder='templates',
                static_folder='static',
                static_url_path='/static')

    @app.route('/')
    def index():
        """Serve the main index page."""
        return render_template('index.html')

    @app.route('/health')
    def health():
        """Health check endpoint."""
        return {'status': 'healthy'}

    return app

if __name__ == '__main__':
    if FLASK_AVAILABLE:
        app = create_app()
        port = int(os.environ.get('PORT', 5000))
        app.run(host='0.0.0.0', port=port, debug=False)
    else:
        print("Flask not available. Install with: pip install flask")
        exit(1)
