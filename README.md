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
```json
{
    "state": "SP",
    "city": "Pereira",
    "street": "Bandeirantes",
    "number": 100,
    "CEP": "00000-000"
}
```

Quanto à response esperada, ela retornará uma mensagem de sucesso

### 09) address/delete/{id} [ DELETE ]
Responsável por remover os dados de um endereço específico. Quanto à response esperada, ela retornará uma mensagem de sucesso.

## Produtos:

Este microserviço possui apenas a entidade de produtos no Banco de Dados, sendo reponsável por operar sobre o catálogo de produtos de uma empresa. Seus atributos são nome, o qual não pode ser repetido, descrição, quantidade no estoque, preço e status.

### 01) /products/create/ [ POST ]
Responsável pela criação de um novo produto. Os parâmetros precisam ser passados no body seguindo o seguinte formato:

```json
{
    "name": "Monitor 3",
    "description": "Melhor experiência como Gamer!",
    "quantity": 500,
    "price": 100.00,
    "status": true
}
```

Note que o name precisa ser único e o status deve ser boolean. Em caso de sucesso, irá retornar uma mensagem de sucesso e o ID do item criado.

### 02) products/fetch/{id}  [ GET ]
Responsável pela busca de um produto pelo id, ou de todos os produtos. Para buscar um produto específico, basta colocar seu id no endpoint da requisição. Caso deseje buscar todos os produtos, basta não incluir nenhum id.

Segue a request esperada para casos de sucesso:
```json
[
    {
        "description": "Melhor experiência como Gamer!",
        "id": 2,
        "name": "Teclado",
        "price": "100.00",
        "quantity": 500,
        "status": 1
    },
    {
        "description": "Guarde suas fotos aqui!",
        "id": 3,
        "name": "Porta Retratão",
        "price": "10.00",
        "quantity": 20,
        "status": 1
    }
]
```

### 03) products/update/{id}  [ PUT ]
Responsável por atualizar os dados de um produto, o qual deve ter seu id especificado na URL da requisição. Quanto ao body esperado, ele deve seguir o seguinte formato:
```json
{
    "name": "Teclado",
    "description": "Melhor experiência como Gamer!",
    "quantity": 500,
    "price": 100.00,
    "status": true
}
```
Além disso, em caso de sucesso, uma resposta indicado sucesso é retornada.

### 04) products/delete/{îd}  [ DELETE ]
Responsável por remover os dados de um produto específico. Para selecionar o produto, basta adicionar seu id ao fim do endpoint. O método executado por este endpoint é responsável por se comunicar com o serviço de Inventário para manter a consistência entre os bancos de dados: se um produto for removido, o mesmo será removido do banco de dados de inventário também.
Quanto à response esperada, ela retornará uma mensagem de sucesso. 

### 05) products/exists/{id}  [ GET ]
Este endpoint é responsável por retornar true caso o produto esteja cadastrado no banco de dados, e false caso contrário. Ele é especificamente chamado pelo micro serviço de inventário, para verificar se o product_id especificado na criação de um relacionamento se refere a um produto existente. O corpo da requisição é vazio, necessitando apenas o token em seu cabeçalho e do ID na URI.

## Inventário

Este microserviço é responsável pelo invetariamento dos produtos contratados por um determinado cliente. Este microserviço funciona como se fosse uma relação muitos para muitos entre clientes e produtos, mas possuem bancos de dados separados dos demais. Os atributos de tal entidade são ID, número de itens, ID do produto contratado, ID do cliente contratante, nome do produto e data de compra / contratação.


### 01) inventory/add_product  [ POST ]
Responsável por adicionar um produto no inventário de um cliente. Em outras palavras, ele cria um relacionamento entre um cliente e um produto, dado que a relação entre eles é de many-to-many. Este método se comunica com os outros dois serviços, chamando o endpoint de clients/exists e products/exists para que seja possível associar apenas objetos existentes no banco de dados. O body da requisição deve seguir o seguinte formato:
```json
{
    "client_id": 4,
    "product_id": 4,
    "number_of_items": 5,
    "purchase_date": "2024-11-01T10:30:00"
}
```
Em caso de sucesso, será retornada uma mensagem indicando o sucesso da operação e o id do objeto criado.

### 02) inventory/list_products_ids/{client_id}  [ GET ]
Responsável por buscar todos os produtos associados a um cliente especificado pelo client_id na URL da requisição. Como não é função do banco de dados de inventário guardar todos os atributos de produtos, ele guarda apenas o id do produto e seu nome. A resposta esperada em caso de sucesso seguirá o seguinte formato:
```json
[
    {
        "id": 2,
        "number_of_items": 5,
        "product_id": 2,
        "product_name": "Teclado",
        "purchase_date": "Fri, 01 Nov 2024 00:00:00 GMT"
    },
    {
        "id": 3,
        "number_of_items": 5,
        "product_id": 2,
        "product_name": "Teclado",
        "purchase_date": "Fri, 01 Nov 2024 00:00:00 GMT"
    }
]
```

### 03) inventory/remove_product/{id}  [ DELETE ]
Responsável por remover um item de um inventário especificado pelo id na URL da requisição. Em caso de sucesso, retornará uma mensagem indicando o sucesso de tal operação.

### 04) inventory/remove_many  [ DELETE ]
Também é responsável por remover itens do inventário, mas neste caso, irá remover todos os itens que possuam referência a um produto ou cliente específico. Para tal, ele possui dois campos em seu corpo, o id da entidade sendo removida e o tipo, podendo ser tanto cliente quanto produto. Tal endpoint é chamado pelos endpoints de remoção de clientes produtos com o objetivo de manter a consistência nos bancos de dados. O formato do body deve ser o seguinte:
```json
{
    "remotion_id": 4,
    "type": "client"
}
ou
{
    "remotion_id": 4,
    "type": "product"
}
```
Em caso de sucesso, retornará uma mensagem indicando isto.




