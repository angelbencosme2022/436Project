create schema ecom;


use ecom;



-- Table for Users
CREATE TABLE Users (
  UID INT NOT NULL AUTO_INCREMENT,
  Fname VARCHAR(50) NOT NULL,
  M_I CHAR(1),
  LName VARCHAR(50) NOT NULL,
  UEmail VARCHAR(100) UNIQUE NOT NULL,
  UPassword VARCHAR(255) NOT NULL,
  URole VARCHAR(20) NOT NULL,
  PRIMARY KEY (UID)
);

ALTER TABLE Users
ADD COLUMN CreditCardNumber VARCHAR(20),
ADD COLUMN CardHolderName VARCHAR(100),
ADD COLUMN ExpirationDate DATE,
ADD COLUMN CVV CHAR(3);


-- Table for Orders
CREATE TABLE Orders (
  OrderID INT NOT NULL AUTO_INCREMENT,
  total_amount DECIMAL(10, 2) NOT NULL,
  OStatus VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UID INT NOT NULL,
  PRIMARY KEY (OrderID),
  FOREIGN KEY (UID) REFERENCES Users(UID)
);

-- Table for Ordered Items
CREATE TABLE Ordered_items (
  order_item_id INT NOT NULL AUTO_INCREMENT,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  OrderID INT NOT NULL,
  PRIMARY KEY (order_item_id)
);

-- Table for Categories
CREATE TABLE Categories (
  cat_id INT NOT NULL AUTO_INCREMENT,
  cat_name VARCHAR(100) NOT NULL,
  Description VARCHAR(300),
  PRIMARY KEY (cat_id)
);

-- Table for Products
CREATE TABLE Products (
  product_id INT NOT NULL AUTO_INCREMENT,
  product_name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock INT NOT NULL,
  arrival DATE,
  cat_id INT NOT NULL,
  PRIMARY KEY (product_id),
  FOREIGN KEY (cat_id) REFERENCES Categories(cat_id)
);

-- Linking Products with Categories (Many-to-Many relationship through Have table)
CREATE TABLE Have (
  cat_id INT NOT NULL,
  product_id INT NOT NULL,
  PRIMARY KEY (cat_id, product_id),
  FOREIGN KEY (cat_id) REFERENCES Categories(cat_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

ALTER TABLE Ordered_items
ADD CONSTRAINT FK_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
ADD CONSTRAINT FK_product_id
FOREIGN KEY (product_id) REFERENCES Products(product_id);

INSERT INTO Users (Fname, M_I, LName, UEmail, UPassword, URole)
VALUES ('John', 'A', 'Doe', 'john.doe@example.com', 'password123', 'customer');

INSERT INTO Categories (cat_name, Description)
VALUES ('Electronics', 'Devices and gadgets');

INSERT INTO Products (product_name, description, price, stock, arrival, cat_id)
VALUES ('Laptop', 'High-performance laptop', 1000.00, 50, '2024-01-01', 1);

INSERT INTO Orders (total_amount, OStatus, UID)
VALUES (1500.00, 'Shipped', 1);

SELECT o.OrderID, oi.quantity, p.product_name, oi.unit_price, o.OStatus
FROM Ordered_items oi
INNER JOIN Orders o ON oi.OrderID = o.OrderID
INNER JOIN Products p ON oi.product_id = p.product_id;

select * from Users;

-- Insert sample data into Users
INSERT INTO Users (Fname, M_I, LName, UEmail, UPassword, URole) VALUES
('Jane', 'B', 'Smith', 'jane.smith@example.com', 'password123', 'admin'),
('Alice', 'C', 'Brown', 'alice.brown@example.com', 'password123', 'customer'),
('Bob', 'D', 'White', 'bob.white@example.com', 'password123', 'customer'),
('Charlie', 'E', 'Black', 'charlie.black@example.com', 'password123', 'supplier');

-- Insert sample data into Categories
INSERT INTO Categories (cat_name, Description) VALUES
('Electronics', 'Devices and gadgets'),
('Home Appliances', 'Various home appliances'),
('Books', 'All kinds of books'),
('Clothing', 'Men and Women Clothing'),
('Toys', 'Toys for children of all ages');

-- Insert sample data into Products
INSERT INTO Products (product_name, description, price, stock, arrival, cat_id) VALUES
('Laptop', 'High-performance laptop', 1200.00, 30, '2024-01-01', 1),
('Smartphone', 'Latest model smartphone', 800.00, 50, '2024-02-15', 1),
('Blender', 'Electric blender', 150.00, 40, '2024-01-10', 2),
('Microwave', '900W microwave', 200.00, 25, '2024-03-05', 2),
('Science Fiction Book', 'A thrilling science fiction novel', 20.00, 100, '2024-01-20', 3),
('Denim Jacket', 'Unisex denim jacket', 75.00, 60, '2024-02-01', 4),
('Action Figure', 'Popular superhero action figure', 25.00, 80, '2024-02-25', 5);




-- Insert sample data into Orders
INSERT INTO Orders (total_amount, OStatus, UID) VALUES
(1200.00, 'Completed', 1),
(800.00, 'Completed', 1),
(200.00, 'Pending', 7),
(40.00, 'Shipped', 8),
(100.00, 'Cancelled', 10);

-- Insert sample data into Ordered_items
INSERT INTO Ordered_items (product_id, quantity, unit_price, OrderID) VALUES
(1, 1, 1200.00, 1),
(2, 1, 800.00, 12),
(4, 1, 200.00, 13),
(5, 2, 20.00, 14),
(7, 4, 25.00, 15);


-- Insert sample data into Have (for Product-Category relationships)
INSERT INTO Have (cat_id, product_id) VALUES
(1, 1), -- Electronics -> Laptop
(1, 2), -- Electronics -> Smartphone
(2, 3), -- Home Appliances -> Blender
(2, 4), -- Home Appliances -> Microwave
(3, 5), -- Books -> Science Fiction Book
(4, 6), -- Clothing -> Denim Jacket
(5, 7); -- Toys -> Action Figure

select * from Users;

select * from Orders;

select * from Ordered_items;

select * from Categories;

select * from Products;

-- Retrieve all ordered items with order and product details.
SELECT o.OrderID, oi.quantity, p.product_name, oi.unit_price, o.OStatus
FROM Ordered_items oi
INNER JOIN Orders o ON oi.OrderID = o.OrderID
INNER JOIN Products p ON oi.product_id = p.product_id;


SELECT u.UID, u.Fname, u.LName, SUM(o.total_amount) AS total_spent
FROM Users u
JOIN Orders o ON u.UID = o.UID
GROUP BY u.UID, u.Fname, u.LName;

CREATE VIEW Active_Orders AS
SELECT o.OrderID, o.total_amount, o.OStatus, u.Fname, u.LName, u.UEmail
FROM Orders o
JOIN Users u ON o.UID = u.UID
WHERE o.OStatus = 'Pending';

CREATE VIEW Completed_Orders AS
SELECT o.OrderID, o.total_amount, o.OStatus, u.Fname, u.LName, u.UEmail
FROM Orders o
JOIN Users u ON o.UID = u.UID
WHERE o.OStatus = 'Completed';

CREATE VIEW Product_Inventory AS
SELECT p.product_name, p.stock, p.price, c.cat_name
FROM Products p
JOIN Categories c ON p.cat_id = c.cat_id;

select * from Product_Inventory;








create database ecom;

create schema ecom;


use ecom;



-- Table for Users
CREATE TABLE Users (
  UID INT NOT NULL AUTO_INCREMENT,
  Fname VARCHAR(50) NOT NULL,
  M_I CHAR(1),
  LName VARCHAR(50) NOT NULL,
  UEmail VARCHAR(100) UNIQUE NOT NULL,
  UPassword VARCHAR(255) NOT NULL,
  URole VARCHAR(20) NOT NULL,
  PRIMARY KEY (UID)
);

ALTER TABLE Users
ADD COLUMN CreditCardNumber VARCHAR(20),
ADD COLUMN CardHolderName VARCHAR(100),
ADD COLUMN ExpirationDate DATE,
ADD COLUMN CVV CHAR(3);


-- Table for Orders
CREATE TABLE Orders (
  OrderID INT NOT NULL AUTO_INCREMENT,
  total_amount DECIMAL(10, 2) NOT NULL,
  OStatus VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UID INT NOT NULL,
  PRIMARY KEY (OrderID),
  FOREIGN KEY (UID) REFERENCES Users(UID)
);

-- Table for Ordered Items
CREATE TABLE Ordered_items (
  order_item_id INT NOT NULL AUTO_INCREMENT,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  OrderID INT NOT NULL,
  PRIMARY KEY (order_item_id)
);

-- Table for Categories
CREATE TABLE Categories (
  cat_id INT NOT NULL AUTO_INCREMENT,
  cat_name VARCHAR(100) NOT NULL,
  Description VARCHAR(300),
  PRIMARY KEY (cat_id)
);

-- Table for Products
CREATE TABLE Products (
  product_id INT NOT NULL AUTO_INCREMENT,
  product_name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock INT NOT NULL,
  arrival DATE,
  cat_id INT NOT NULL,
  PRIMARY KEY (product_id),
  FOREIGN KEY (cat_id) REFERENCES Categories(cat_id)
);

-- Linking Products with Categories (Many-to-Many relationship through Have table)
CREATE TABLE Have (
  cat_id INT NOT NULL,
  product_id INT NOT NULL,
  PRIMARY KEY (cat_id, product_id),
  FOREIGN KEY (cat_id) REFERENCES Categories(cat_id),
  FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

ALTER TABLE Ordered_items
ADD CONSTRAINT FK_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
ADD CONSTRAINT FK_product_id
FOREIGN KEY (product_id) REFERENCES Products(product_id);

INSERT INTO Users (Fname, M_I, LName, UEmail, UPassword, URole)
VALUES ('John', 'A', 'Doe', 'john.doe@example.com', 'password123', 'customer');

INSERT INTO Categories (cat_name, Description)
VALUES ('Electronics', 'Devices and gadgets');

INSERT INTO Products (product_name, description, price, stock, arrival, cat_id)
VALUES ('Laptop', 'High-performance laptop', 1000.00, 50, '2024-01-01', 1);

INSERT INTO Orders (total_amount, OStatus, UID)
VALUES (1500.00, 'Shipped', 1);

SELECT o.OrderID, oi.quantity, p.product_name, oi.unit_price, o.OStatus
FROM Ordered_items oi
INNER JOIN Orders o ON oi.OrderID = o.OrderID
INNER JOIN Products p ON oi.product_id = p.product_id;

select * from Users;

-- Insert sample data into Users
INSERT INTO Users (Fname, M_I, LName, UEmail, UPassword, URole) VALUES
('Jane', 'B', 'Smith', 'jane.smith@example.com', 'password123', 'admin'),
('Alice', 'C', 'Brown', 'alice.brown@example.com', 'password123', 'customer'),
('Bob', 'D', 'White', 'bob.white@example.com', 'password123', 'customer'),
('Charlie', 'E', 'Black', 'charlie.black@example.com', 'password123', 'supplier');

-- Insert sample data into Categories
INSERT INTO Categories (cat_name, Description) VALUES
('Electronics', 'Devices and gadgets'),
('Home Appliances', 'Various home appliances'),
('Books', 'All kinds of books'),
('Clothing', 'Men and Women Clothing'),
('Toys', 'Toys for children of all ages');

-- Insert sample data into Products
INSERT INTO Products (product_name, description, price, stock, arrival, cat_id) VALUES
('Laptop', 'High-performance laptop', 1200.00, 30, '2024-01-01', 1),
('Smartphone', 'Latest model smartphone', 800.00, 50, '2024-02-15', 1),
('Blender', 'Electric blender', 150.00, 40, '2024-01-10', 2),
('Microwave', '900W microwave', 200.00, 25, '2024-03-05', 2),
('Science Fiction Book', 'A thrilling science fiction novel', 20.00, 100, '2024-01-20', 3),
('Denim Jacket', 'Unisex denim jacket', 75.00, 60, '2024-02-01', 4),
('Action Figure', 'Popular superhero action figure', 25.00, 80, '2024-02-25', 5);




-- Insert sample data into Orders
INSERT INTO Orders (total_amount, OStatus, UID) VALUES
(1200.00, 'Completed', 1),
(800.00, 'Completed', 1),
(200.00, 'Pending', 7),
(40.00, 'Shipped', 8),
(100.00, 'Cancelled', 10);

-- Insert sample data into Ordered_items
INSERT INTO Ordered_items (product_id, quantity, unit_price, OrderID) VALUES
(1, 1, 1200.00, 1),
(2, 1, 800.00, 12),
(4, 1, 200.00, 13),
(5, 2, 20.00, 14),
(7, 4, 25.00, 15);


-- Insert sample data into Have (for Product-Category relationships)
INSERT INTO Have (cat_id, product_id) VALUES
(1, 1), -- Electronics -> Laptop
(1, 2), -- Electronics -> Smartphone
(2, 3), -- Home Appliances -> Blender
(2, 4), -- Home Appliances -> Microwave
(3, 5), -- Books -> Science Fiction Book
(4, 6), -- Clothing -> Denim Jacket
(5, 7); -- Toys -> Action Figure

select * from Users;

select * from Orders;

select * from Ordered_items;

select * from Categories;

select * from Products;

-- Retrieve all ordered items with order and product details.
SELECT o.OrderID, oi.quantity, p.product_name, oi.unit_price, o.OStatus
FROM Ordered_items oi
INNER JOIN Orders o ON oi.OrderID = o.OrderID
INNER JOIN Products p ON oi.product_id = p.product_id;


SELECT u.UID, u.Fname, u.LName, SUM(o.total_amount) AS total_spent
FROM Users u
JOIN Orders o ON u.UID = o.UID
GROUP BY u.UID, u.Fname, u.LName;

CREATE VIEW Active_Orders AS
SELECT o.OrderID, o.total_amount, o.OStatus, u.Fname, u.LName, u.UEmail
FROM Orders o
JOIN Users u ON o.UID = u.UID
WHERE o.OStatus = 'Pending';

CREATE VIEW Completed_Orders AS
SELECT o.OrderID, o.total_amount, o.OStatus, u.Fname, u.LName, u.UEmail
FROM Orders o
JOIN Users u ON o.UID = u.UID
WHERE o.OStatus = 'Completed';

CREATE VIEW Product_Inventory AS
SELECT p.product_name, p.stock, p.price, c.cat_name
FROM Products p
JOIN Categories c ON p.cat_id = c.cat_id;

select * from Product_Inventory;

Alter Table Users drop column balance;


select * from Users;





create database ecom;

use ecom;


-- Drop existing foreign key constraints first if they already exist
ALTER TABLE Ordered_items
DROP FOREIGN KEY FK_OrderID,
DROP FOREIGN KEY FK_product_id;

-- Add updated foreign key constraints with ON DELETE and ON UPDATE cascades
ALTER TABLE Ordered_items
ADD CONSTRAINT FK_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT FK_product_id
FOREIGN KEY (product_id) REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Modify foreign key for Users in Orders table
ALTER TABLE Orders
DROP FOREIGN KEY Orders_ibfk_1; -- Replace with the actual foreign key name if different

ALTER TABLE Orders
ADD CONSTRAINT FK_UID
FOREIGN KEY (UID) REFERENCES Users(UID)
ON DELETE CASCADE
ON UPDATE CASCADE;





-- Drop and re-add constraints for the Have table
ALTER TABLE Have
DROP FOREIGN KEY Have_ibfk_1, -- Replace with actual foreign key names if different
DROP FOREIGN KEY Have_ibfk_2;

ALTER TABLE Have
ADD CONSTRAINT FK_Have_cat_id
FOREIGN KEY (cat_id) REFERENCES Categories(cat_id)
ON DELETE CASCADE
ON UPDATE CASCADE,
ADD CONSTRAINT FK_Have_product_id
FOREIGN KEY (product_id) REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;





select * from Users;


Alter table Products drop column arrival;

alter table Users drop column balance;

Select * from Products;

Select * from Users;

select * from Orders;
