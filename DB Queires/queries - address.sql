USE clients_context;

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

SELECT * FROM address;

INSERT INTO address (client_id, state, city, street, number, CEP)
VALUES (1, 'SP', 'São Paulo', 'Rua Pereira', 515, '05500-060');

UPDATE address
SET state = 'MG', city = 'São Paulo', street = 'Rua Pereira', number = 515, CEP = '05500-060'
WHERE id = 1;

DELETE FROM address
WHERE id = 2;

DROP TABLE address;

SHOW CREATE TABLE address;
ALTER TABLE address DROP FOREIGN KEY fk_id_client;
ALTER TABLE address
ADD CONSTRAINT fk_id_client
FOREIGN KEY (client_id) REFERENCES clients(id)
ON DELETE CASCADE;


