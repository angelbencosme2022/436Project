import mysql.connector


db = mysql.connector.connect(
    host="localhost",
    user="root",
    password= "your_password",
    database="ecom"
    
)



mycursor = db.cursor()

# Execute a query to select all from the Users table
mycursor.execute("SELECT * FROM Users")

# Fetch all the rows from the executed query
result = mycursor.fetchall()


# Print the result
for row in result:
    print(row)
