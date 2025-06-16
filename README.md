# Inmetrics---Desafios

# Introdução

O projeto em questão consiste a um código Back-end desenvovlido em Flask (Python) que implementa um sistema de cadastro de clientes e produtos. Baseado na teoria de BDD, o projeto segue uma arquitetura de micro-serviços sendo cada um independente do outro em certo grau. Além disso, o projeto conta com testes automatizados, desenvolvidos com Robot framework e seguindo a estrutura de Guerkins, se aproximando de uma linguagem falada, e também conta com algoritmo de monitoramento sintético, o qual verifica a disponibilidade dos microserviços periodicamente.

# Funcionamento do Código

O projeto possui 4 microserviços: Clientes, Produtos, Inventário e Autenticação.
Antes da explicação individual de cada microserviço, é importante mencionar que todos microserviços exigem autenticação via bearer token, o qual é obtido através dos Endpoints de Autenticação.

## Clientes:
Este microserviço possui o CRUD de dois elementos, cliente e endereço, possuindo relação um pra muitos. A entidade cliente tem 5 atributos, sendo eles: id, name, cpf, email e balance. Enquanto a entidade endereço tem 7 atributos, sendo eles id, client_id, state, city, street, number e cep. Note que os campos de ID não precisam ser preenchidos, o próprio Banco de Dados os gera.

01) clients/create  [ POST ]
Responsável pela cadastro de um cliente novo no sistema. Os campos de email e cpf não podem ser repetidos, enquanto os campos de cpf, email e cep devem possuir formato corretos.
A seguir tem-se o _BODY_ esperado:
```json
{
    "name": "Arthur",
    "email": "arthur.giovanini@inmetrics.com.br",
    "cpf": "454.090.000-00",
    "balance": 30.25
}
```
A resposta esperada consiste em uma mensagem de sucesso e o ID do objeto criado

02) clients/fetch/{id}  [ GET ]
Responsável pela busca de um cliente específico no sistema. Se desejar, é possível omitir o ID da url para buscar todos os clientes.
A requisição não tem _BODY_ e possui resposta esperada:
```json
[
  {
    "id": 1,
    "name": "Pedro",
    "email": "arthur.giovanini@inmetrics.com.br",
    "cpf": "454.090.000-00",
    "balance": "30.25"
  },
  {
    "id": 4,
    "name": "Vinícius",
    "email": "Vinícius_Peixoto@inmetrics.com.br",
    "cpf": "454.454.454-27",
    "balance": "30.25"
  }
]
```



