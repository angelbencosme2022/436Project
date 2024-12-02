from flask import Flask, request, render_template

app = Flask(__name__)

@app.route('/')
def login_page():
    # Render the HTML form
    return render_template('index.html')  # Ensure your HTML file is in a 'templates' folder

@app.route('/login', methods=['POST'])
def login():
    # Get form data
    email = request.form['Email']
    password = request.form['password']

    # For now, just print the credentials
    print(f"Email: {email}, Password: {password}")

    # Add your login logic here (e.g., check credentials in a database)
    if email == "admin@example.com" and password == "password":
        return "Login Successful!"
    else:
        return "Invalid credentials. Please try again."

if __name__ == '__main__':
    app.run(debug=True)
