CREATE DATABASE clients_context;

USE clients_context;
CREATE TABLE clients (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  cpf VARCHAR(14) UNIQUE NOT NULL,
  balance DECIMAL(10, 2),
  CHECK (email REGEXP '^[^@]+@[^@]+\.[^@]+$'),
  CHECK (cpf REGEXP '^([0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}|[0-9]{11})$')
);

CREATE TABLE address (
  id INT AUTO_INCREMENT PRIMARY KEY,
  client_id INT NOT NULL,
  state VARCHAR(2) NOT NULL,
  city VARCHAR(30) NOT NULL,
  street VARCHAR(30) NOT NULL,
  number INT NOT NULL,
  CEP VARCHAR(14) NOT NULL,
  CHECK (CEP REGEXP '^[0-9]{5}-[0-9]{3}$'),
  CONSTRAINT fk_id_client FOREIGN KEY(client_id) 
    REFERENCES clients(id) ON DELETE CASCADE
);

CREATE DATABASE authentication_context;
USE authentication_context;

CREATE TABLE user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL
);

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
