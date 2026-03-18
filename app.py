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
    app.run(debug=True, port=5000)
