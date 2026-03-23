from flask import Flask, render_template

# Create Flask application instance
app = Flask(__name__)

# Enable debug mode for development
app.config['DEBUG'] = True

@app.route('/')
def index():
    """Render the main page of the application."""
    return render_template('index.html', title='Flask App')

@app.errorhandler(404)
def page_not_found(e):
    """Handle 404 errors."""
    return render_template('index.html', title='Page Not Found'), 404

if __name__ == '__main__':
    # Run the Flask application
    app.run(host='0.0.0.0', port=5000)
