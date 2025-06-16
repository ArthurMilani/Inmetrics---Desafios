# Inmetrics---Desafios

# Introdução && Cobertura

O projeto em questão consiste a um código Back-end desenvovlido em Flask (Python) que implementa um sistema de cadastro de clientes e produtos. Baseado na teoria de BDD, o projeto segue uma arquitetura de micro-serviços sendo cada um independente do outro em certo grau. Além disso, o projeto conta com testes automatizados, desenvolvidos com Robot framework e seguindo a estrutura de Guerkins, se aproximando de uma linguagem falada, e também conta com algoritmo de monitoramento sintético, o qual verifica a disponibilidade dos microserviços periodicamente.

# Funcionamento do Código

O projeto possui 4 microserviços: Clientes, Produtos, Inventário e Autenticação.
Antes da explicação individual de cada microserviço, é importante mencionar que todos microserviços exigem autenticação via bearer token, o qual é obtido através dos Endpoints de Autenticação.

## Clientes:
Este microserviço possui o CRUD de dois elementos, cliente e endereço, possuindo relação um pra muitos. A entidade cliente tem 5 atributos, sendo eles: id, name, cpf, email e balance. Enquanto a entidade endereço tem 7 atributos, sendo eles id, client_id, state, city, street, number e cep. Note que os campos de ID não precisam ser preenchidos, o próprio Banco de Dados os gera.

### 01) clients/create  [ POST ]

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

### 02) clients/fetch/{id}  [ GET ]

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
### 03) clients/update/{id}  [ PUT ]

Responsável por atualizar um cliente específico, cujo ID deve ser especificado na URL da requisição obrigatoriamente.
O _BODY_ da requisição esperado é igual ao do Endpoint de criação de cliente:
```json
{
    "name": "Arthur",
    "email": "arthur.giovanini@inmetrics.com.br",
    "cpf": "454.090.000-00",
    "balance": 30.25
}
```
E a resposta esperada consiste em uma mensagem de sucesso.

### 04) clients/delete/{id} [ DELETE ]

Responsável por remover um cliente específico, cujo ID deve ser especificado na URL da requisição obrigatoriamente.
A requisição não tem _BODY_ e possui resposta esperada uma mensagem de sucesso.

### 05) /clients/exists/{id} [ GET ]

Responsável por retornar se um cliente específico está registrado ou não no sistema. Retorna True se estiver e False se não estiver.

### 06) address/create  [ POST ]
Responsável pela criação dos endereços. Os atributos dos endereços precisam ser passados no _BODY_ da requisição com o seguinte formato:
```json
{
    "client_id": 1,
    "state": "SP",
    "city": "Andradina",
    "street": "Bandeirantes",
    "number": 100,
    "CEP": "00000-000"
}
```
Quanto à response esperada, ela retornará uma mensagem de sucesso e o ID do objeto criado.

### 07) address/fetch/{client_id} [ GET ]
Responsável pela busca dos endereços de um determinado cliente, cujo ID deve ser especificado na URL da requisição. Além disso, é possível buscar todos endereços no sistema ao omitir o ID na URL.
A seguir está a response bem sucedida:
```json
[
    {
        "CEP": "00000-000",
        "city": "Andradina",
        "client_id": 1,
        "id": 8,
        "number": 100,
        "state": "SP",
        "street": "Bandeirantes"
    },
    {
        "CEP": "00000-000",
        "city": "Andradina",
        "client_id": 1,
        "id": 9,
        "number": 100,
        "state": "SP",
        "street": "Bandeirantes"
    }
]
```

### 08) address/update/{id}  [ PUT ]
Responsável por atualizar os dados de um endereço específico. Os atributos precisam ser passados no _BODY_ com o seguinte formato:
{
    "state": "SP",
    "city": "Pereira",
    "street": "Bandeirantes",
    "number": 100,
    "CEP": "00000-000"
}

Quanto à response esperada, ela retornará uma mensagem de sucesso

### 09) address/delete/{id} [ DELETE ]
Responsável por remover os dados de um endereço específico. Quanto à response esperada, ela retornará uma mensagem de sucesso.



