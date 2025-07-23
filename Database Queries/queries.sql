CREATE DATABASE clients_context;

USE clients_context;
CREATE TABLE clients (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
cpf VARCHAR(14) UNIQUE NOT NULL,
balance DECIMAL(10, 2),
CHECK (email REGEXP '^[^@]+@[^@]+\\.[^@]+$'),
CHECK (cpf REGEXP '^([0-9]{3}\\.[0-9]{3}\\.[0-9]{3}-[0-9]{2}|[0-9]{11})$')
);

DROP TABLE clientes;

INSERT INTO clients (name, email, cpf, balance)
VALUES ('Pedro', 'arthurusp@usp', '454.187.188-27', 2000.05);

SELECT * FROM clients;

UPDATE clients
SET name = 'Arthur', email = 'arthurusp@usp.br', cpf = '454.187.188-27', balance = 2000.05
WHERE id = 1;

CREATE USER 'linux'@'%' IDENTIFIED BY 'pacote321';
GRANT ALL PRIVILEGES ON *.* TO 'linux'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

DELETE FROM clients WHERE id = 1;

