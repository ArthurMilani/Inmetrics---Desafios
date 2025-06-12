*** Settings ***
Library  RequestsLibrary
Library  String
Resource    ../steps/authSteps.robot
Resource    ../steps/clientsSteps.robot


*** Test Cases ***
#Criação de Cliente
POSITIVE - Criação de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um cliente no sistema com dados corretos
    ENTÃO o sistema deve salvar o cliente no banco de dados e retornar sucesso


NEGATIVE - Criação de cliente com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um cliente no sistema com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos


NEGATIVE - Criação de cliente com dados repetidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um cliente no sistema com dados repetidos
    ENTÃO o sistema deve retornar erro de dados repetidos

# Atualização de Cliente
POSITIVE - Atualização de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o cliente com dados corretos
    ENTÃO o sistema deve atualizar os dados do cliente no banco de dados e retornar sucesso

NEGATIVE - Atualização de cliente com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o cliente com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos

# NEGATIVE - Atualização de cliente com dados repetidos
#     DADO que o usuário possui um token de autenticação válido
#     QUANDO ele faz a requisição de atualizar o cliente com dados repetidos
#     ENTÃO o sistema deve retornar erro de dados repetidos

#Busca de Cliente
POSITIVE - Busca de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar um cliente existente no sistema
    ENTÃO o sistema deve retornar os dados do cliente com sucesso

POSITIVE - Busca de todos clientes
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar todos os clientes no sistema
    ENTÃO o sistema deve retornar a lista de todos os clientes com sucesso

NEGATIVE - Busca de cliente inexistente
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar um cliente inexistente no sistema
    ENTÃO o sistema deve retornar erro de cliente não encontrado

# Deleção de Cliente
POSITIVE - Deleção de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de deletar um cliente existente no sistema
    ENTÃO o sistema deve deletar o cliente do banco de dados e retornar sucesso


#Verificar se Cliente Existe


