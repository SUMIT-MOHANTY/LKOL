from flask import Flask, render_template
import logging
import os

app = Flask(__name__)

# Configure logging for production visibility
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

@app.route('/')
def index():
    """Serve the index page with basic template rendering."""
    try:
        logger.info("Serving index page")
        return render_template('index.html')
    except Exception as e:
        logger.error(f"Error serving index page: {str(e)}")
        return f"Error rendering template: {str(e)}", 500

@app.route('/health')
def health_check():
    """Health check endpoint for deployment monitoring."""
    return {"status": "healthy", "service": "flask-app"}, 200

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors gracefully."""
    return {"error": "Resource not found"}, 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors gracefully."""
    logger.error(f"Internal server error: {str(error)}")
    return {"error": "Internal server error"}, 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    host = os.environ.get('HOST', '0.0.0.0')
    logger.info(f"Starting Flask application on {host}:{port}")
    app.run(host=host, port=port, debug=False)
