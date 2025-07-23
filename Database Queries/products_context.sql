CREATE DATABASE products_context;
USE products_context;

CREATE TABLE products(
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) UNIQUE NOT NULL,
description TEXT NOT NULL,
price DECIMAL(10, 2) NOT NULL,
quantity INT NOT NULL,
status BOOLEAN DEFAULT TRUE
);

INSERT INTO products (name, description, price, quantity, status)
VALUES ("Porta Retratin", "Guarde suas fotos aqui!", 10.00, 20.5, TRUE);

SELECT * FROM products;

UPDATE products
SET name = "Retrato", description = "Sua foto!", price = 1.00, quantity = 1
WHERE id = 1; 

DELETE from products
WHERE id = 3;
