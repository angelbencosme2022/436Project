from flask import Flask, request, render_template
import mysql.connector

db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="A445a445.123.525",
    database="ecom"
)

mycursor = db.cursor()

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

    # Query the Users table
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Users WHERE UEmail = %s AND UPassword = %s", (email, password))
    user = cursor.fetchone()

    # Check if user exists
    if user:
        return "Login Successful!"
    else:
        # Render the login page again with an error message
        return render_template('index.html', error="Invalid credentials. Please try again.")
    
    
@app.route('/register_page')
def register_page():
    # Render the HTML form
    return render_template('signUp.html')
    
@app.route('/register', methods=['POST'])

def register():
    # Get form data
    first_name = request.form['first-name']
    middle_name = request.form['middle-name']
    last_name = request.form['last-name']
    email = request.form['email']
    password = request.form['password']

    # Insert the user into the Users table
    cursor = db.cursor()
    cursor.execute("INSERT INTO Users (FName, M_I , LName , UEmail, UPassword,URole) VALUES (%s, %s , %s, %s ,%s , %s)", (first_name ,middle_name, last_name, email, password , 'customer'))
    db.commit()

    return "Registration Successful!"


if __name__ == '__main__':
    app.run(debug=True)


