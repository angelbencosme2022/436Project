from flask import Flask, request, render_template, redirect, url_for, jsonify

# import mysql.connector  # This line is a duplicate and can be removed
from flask_cors import CORS

# app = Flask(__name__)  # This line is a duplicate and can be removed
import mysql.connector



# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="A445a445.123.525",
    database="ecom"
)

app = Flask(__name__)
CORS(app)

@app.route('/')
def login_page():
    # Render the login page
    return render_template('index.html')  # Ensure this file is in a 'templates' folder

@app.route('/login', methods=['POST'])
def login():
    global curr_Email
    # Get form data
    email = request.form['Email']
    curr_Email = email
    password = request.form['password']

    # Query the Users table
    cursor = db.cursor()
    cursor.execute("SELECT * FROM Users WHERE UEmail = %s AND UPassword = %s", (email, password))
    user = cursor.fetchone()

    # Check if user exists
    if user:
        # Redirect to the appropriate page based on user role
        global curr_UID
        curr_UID = user[0]
        if user[6] == 'admin':  # Assuming URole is the 6th column in the Users table
            return redirect(url_for('admin_login'))
        else:
            return redirect(url_for('search_page'))
    else:
        # Render the login page again with an error message
        return render_template('index.html', error="Invalid credentials. Please try again.")

@app.route('/register_page')
def register_page():
    # Render the registration page
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
    cursor.execute(
        "INSERT INTO Users (FName, M_I, LName, UEmail, UPassword, URole) VALUES (%s, %s, %s, %s, %s, %s)",
        (first_name, middle_name, last_name, email, password, 'customer')
    )
    db.commit()

    # Redirect to the login page after successful registration
    return redirect(url_for('login_page'))

from flask import jsonify
from datetime import datetime


@app.route('/search_page', methods=['GET'])
def search_page():
    cursor = db.cursor()
    cursor.execute("SELECT product_name, price, description FROM Products")
    products = cursor.fetchall()

    product_list = [
        {
            'product_name': product[0],
            'price': product[1],
            'description': product[2]
        }
        for product in products
    ]

    # Check if it's an AJAX request
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return jsonify(product_list)
    
    # For regular browser requests
    return render_template('search.html', products=product_list)



@app.route('/add_funds', methods=['POST'])
def add_funds():
    # Check if the balance column exists, if not, add it
    cursor = db.cursor()
    cursor.execute("SHOW COLUMNS FROM Users LIKE 'balance'")
    result = cursor.fetchone()
    if not result:
        cursor.execute("ALTER TABLE Users ADD COLUMN balance INT DEFAULT 0")
        db.commit()

        # Get the amount to add and the user's email
    amount = int(request.form['amount'])
    #email = request.form['email']

        # Update the user's balance
    print(curr_Email)
    cursor.execute("UPDATE Users SET balance = balance + %s WHERE UEmail = %s", (amount, curr_Email))
    db.commit()

    return jsonify({"message": "Funds added successfully"})


@app.route('/checkout_page', methods=['GET'])
def checkout_page():
    # Get the current user's balance
    cursor = db.cursor()
    cursor.execute("SELECT balance FROM Users WHERE UID = %s", (curr_UID,))
    user_balance = cursor.fetchone()[0]
    
    # Render the checkout page with the user's balance
    return jsonify({"balance": user_balance})

@app.route('/confirm_checkout', methods=['POST'])
def confirm_checkout():
    total_amount = float(request.form['total_amount'])
    OStatus = 'pending'
    created_at = datetime.now()

    # Check if the user has enough balance
    cursor = db.cursor()
    cursor.execute("SELECT balance FROM Users WHERE UEmail = %s", (curr_Email,))
    user_balance = cursor.fetchone()[0]

    if user_balance >= total_amount:
        # Deduct the total amount from the user's balance
        cursor.execute("UPDATE Users SET balance = balance - %s WHERE UEmail = %s", (total_amount, curr_Email))
        db.commit()

        # Add the total amount to the user with UserID = 7
        cursor.execute("UPDATE Users SET balance = balance + %s WHERE UID = %s", (total_amount, 7))
        db.commit()

        # Insert the order into the Orders table
        cursor.execute(
            "INSERT INTO Orders (total_amount, OStatus, created_at, UID) VALUES (%s, %s, %s, %s)",
            (total_amount, OStatus, created_at, curr_UID)
        )
        db.commit()

        return jsonify({"message": "Order confirmed successfully"})
    else:
        return jsonify({"error": "Insufficient balance"}), 400



@app.route('/admin_login')
def admin_login():
    cursor = db.cursor()
    cursor.execute("SELECT product_id, product_name, price, description FROM Products")
    products = cursor.fetchall()

    product_list = [
        {
            'product_id': product[0],
            'product_name': product[1],
            'price': product[2],
            'description': product[3]
        }
        for product in products
    ]

    return render_template('admin_login.html', products=product_list)

@app.route('/delete_product/<int:product_id>', methods=['POST'])
def delete_product(product_id):
    cursor = db.cursor()
    cursor.execute("DELETE FROM Products WHERE product_id = %s", (product_id,))
    db.commit()
    return jsonify({"message": "Product deleted successfully"})

@app.route('/edit_product/<int:product_id>', methods=['POST'])
def edit_product(product_id):
    data = request.get_json()
    product_name = data.get('product_name')
    price = data.get('price')
    description = data.get('description')

    if not product_name or not price or not description:
        return jsonify({"error": "All fields are required"}), 400

    cursor = db.cursor()
    cursor.execute(
        "UPDATE Products SET product_name = %s, price = %s, description = %s WHERE product_id = %s",
        (product_name, price, description, product_id)
    )
    db.commit()
    return jsonify({"message": "Product updated successfully"})

@app.route('/add_product', methods=['POST'])
def add_product():
    data = request.get_json()
    try:
        product_name = data['product_name']
        description = data['description']
        price = data['price']
        stock = data['stock']
        cat_id = data['cat_id']
    except KeyError as e:
        return jsonify({"error": f"Missing form data: {str(e)}"}), 400

    cursor = db.cursor()
    cursor.execute(
        "INSERT INTO Products (product_name, description, price, stock, cat_id) VALUES (%s, %s, %s, %s, %s)",
        (product_name, description, price, stock, cat_id)
    )
    db.commit()
    return jsonify({"message": "Product added successfully"})






if __name__ == '__main__':
    app.run(debug=True)



