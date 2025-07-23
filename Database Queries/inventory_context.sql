CREATE DATABASE inventory_context;
USE inventory_context;

CREATE TABLE client_products(
id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT NOT NULL,
product_id INT NOT NULL,
product_name VARCHAR(100) NOT NULL,
number_of_items INT NOT NULL,
purchase_date DATE
);

DROP TABLE client_products;

SELECT * FROM client_products;