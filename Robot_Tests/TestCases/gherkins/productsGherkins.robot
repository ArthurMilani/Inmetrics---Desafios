*** Settings ***
Library  RequestsLibrary
Library  String
Resource    ../steps/authSteps.robot
Resource    ../steps/productsSteps.robot

*** Test Cases ***
#Criação de Produtos

POSITIVE - Criar produto com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um produto no sistema com dados corretos
    ENTÃO o sistema deve salvar o produto no banco de dados e retornar sucesso


NEGATIVE - Criar produto com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um produto no sistema com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos


NEGATIVE - Criar produto com dados repetidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um produto no sistema com dados repetidos
    ENTÃO o sistema deve retornar erro de dados repetidos


# Atualização de Produto
POSITIVE - Atualizar produto com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o produto com dados corretos
    ENTÃO o sistema deve atualizar os dados do produto no banco de dados e retornar sucesso


NEGATIVE - Atualizar produto com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o produto com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos


# NEGATIVE - Atualizar produto com dados repetidos
#     DADO que o usuário possui um token de autenticação válido
#     QUANDO ele faz a requisição de atualizar o produto com dados repetidos
#     ENTÃO o sistema deve retornar erro de dados repetidos

# Busca de Produto
POSITIVE - Buscar produto com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar um produto existente no sistema
    ENTÃO o sistema deve retornar os dados do produto com sucesso

POSITIVE - Buscar todos produtos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar todos os produtos no sistema
    ENTÃO o sistema deve retornar a lista de todos os produtos com sucesso


NEGATIVE - Buscar produto inexistente
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar um produto inexistente no sistema
    ENTÃO o sistema deve retornar erro de produto não encontrado


# Deleção de Produto
POSITIVE - Deletar produto com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de deletar um produto existente no sistema
    ENTÃO o sistema deve deletar o produto do banco de dados e retornar sucesso