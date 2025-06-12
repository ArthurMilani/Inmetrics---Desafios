*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR
Resource    ../steps/authSteps.robot
Resource    ../steps/addressSteps.robot

*** Test Cases ***
# Criação de Endereço
POSITIVE - Criação de endereço com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um endereço no sistema com dados corretos
    ENTÃO o sistema deve salvar o endereço no banco de dados e retornar sucesso

NEGATIVE - Criação de endereço com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um endereço no sistema com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos

NEGATIVE - Criação de endereço com ID de cliente inexistente
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de criar um endereço no sistema com ID de cliente inexistente
    ENTÃO o sistema deve retornar erro de cliente não encontrado

# Atualização de Endereço
POSITIVE - Atualização de endereço com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o endereço com dados corretos
    ENTÃO o sistema deve atualizar os dados do endereço no banco de dados e retornar sucesso


NEGATIVE - Atualização de endereço com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de atualizar o endereço com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos

# NEGATIVE - Atualização de endereço com ID de cliente inexistente
#     DADO que o usuário possui um token de autenticação válido
#     QUANDO ele faz a requisição de atualizar o endereço com ID de cliente inexistente
#     ENTÃO o sistema deve retornar erro de cliente não encontrado


# Busca de Endereço
POSITIVE - Busca de endereço com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar endereços de um cliente
    ENTÃO o sistema deve retornar os dados dos endereços com sucesso


POSITIVE - Busca de todos endereços
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar todos os endereços no sistema
    ENTÃO o sistema deve retornar os dados dos endereços com sucesso


# NEGATIVE - Busca de endereço de cliente inexistente
#     DADO que o usuário possui um token de autenticação válido
#     QUANDO ele faz a requisição de buscar endereços de um cliente inexistente
#     ENTÃO o sistema deve retornar erro de cliente não encontrado


# Deleção de Endereço
POSITIVE - Deleção de endereço com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de deletar um endereço existente no sistema
    ENTÃO o sistema deve deletar o endereço do banco de dados e retornar sucesso

