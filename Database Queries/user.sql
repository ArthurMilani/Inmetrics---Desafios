CREATE DATABASE authentication_context;


USE authentication_context;

CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

INSERT INTO user (username, password)
VALUES ('Anakin', 'Teste');

SELECT * FROM user;

DELETE FROM user WHERE username = 'Anakin';