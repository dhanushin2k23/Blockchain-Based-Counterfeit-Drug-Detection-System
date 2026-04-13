from flask import Flask, render_template, send_from_directory

# Create the Flask app.
# - template_folder is set to "public" where your HTML files reside.
# - static_folder is set to "src" for your CSS, JS, images, etc.
app = Flask(__name__, template_folder='public', static_folder='src')

# Route for the main HTML page
@app.route('/')
def index():
    return render_template('index.html')

# Route for the costumer (customer) page
@app.route('/customer.html')
def customer():
    return render_template('customer.html')

# Route for the manufacturer page
@app.route('/manufacturer.html')
def manufacturer():
    return render_template('manufacturer.html')

# Route for the retailer page
@app.route('/retailer.html')
def retailer():
    return render_template('Retailer.html')

# Route to serve any static files (CSS, JS, images, etc.) from the "src" folder
@app.route('/src/<path:filename>')
def serve_static(filename):
    return send_from_directory('src', filename)

# Run the Flask app in debug mode
if __name__ == '__main__':
    app.run(debug=True)