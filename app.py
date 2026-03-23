import os
from flask import Flask, render_template

instance_path = os.path.dirname(os.path.abspath(__file__))
app = Flask(__name__, 
            template_folder=os.path.join(instance_path, 'templates'),
            static_folder=os.path.join(instance_path, 'static'))

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    # Using 0.0.0.0 helps with access in some VM/Docker environments, but for local, 127.0.0.1 is fine too.
    app.run(debug=True, host='0.0.0.0', port=5000)
