# Inmetrics---Desafios

# Introdução

O projeto em questão consiste a um código Back-end desenvovlido em Flask (Python) que implementa um sistema de cadastro de clientes e produtos. Baseado na teoria de BDD, o projeto segue uma arquitetura de micro-serviços sendo cada um independente do outro em certo grau. Além disso, o projeto conta com testes automatizados, desenvolvidos com Robot framework e seguindo a estrutura de Guerkins, se aproximando de uma linguagem falada, e também conta com algoritmo de monitoramento sintético, o qual verifica a disponibilidade dos microserviços periodicamente.

# Funcionamento do Código

O projeto possui 4 microserviços: Clientes, Produtos, Inventário e Autenticação.
Antes da explicação individual de cada microserviço, é importante mencionar que todos microserviços exigem autenticação via bearer token, o qual é obtido através dos Endpoints de Autenticação.

## Clientes:
Este microserviço possui o CRUD de dois elementos, cliente e endereço, possuindo relação um pra muitos. A entidade cliente tem 5 atributos, sendo eles: id, name, cpf, email e balance. Enquanto a entidade endereço tem 7 atributos, sendo eles id, client_id, state, city, street, number e cep.

