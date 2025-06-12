*** Settings ***
Library  RequestsLibrary
Library  String
Resource    ../steps/authSteps.robot
Resource    ../steps/inventorySteps.robot

*** Test Cases ***
# Adição de itens no inventário de um cliente
POSITIVE - Adicionar item no inventário com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de adicionar um item no inventário do cliente com dados corretos
    ENTÃO o sistema deve salvar o item no inventário e retornar sucesso

NEGATIVE - Adicionar item no inventário com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de adicionar um item no inventário do cliente com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos

NEGATIVE - Adicionar item no inventário com cliente inexistente
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de adicionar um item no inventário com um cliente inexistente
    ENTÃO o sistema deve retornar erro de cliente não encontrado

NEGATIVE - Adicionar item no inventário com produto inexistente
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de adicionar um item no inventário com um produto inexistente
    ENTÃO o sistema deve retornar erro de produto não encontrado

#Busca de produtos de um cliente
POSITIVE - Buscar inventário de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de buscar o inventário de um cliente existente
    ENTÃO o sistema deve retornar o inventário do cliente com sucesso


# NEGATIVE - Buscar inventário de cliente inexistente
#     DADO que o usuário possui um token de autenticação válido
#     QUANDO ele faz a requisição de buscar o inventário de um cliente inexistente
#     ENTÃO o sistema deve retornar erro de cliente não encontrado


# Remoção de muitos itens do inventário por id de produto ou cliente
POSITIVE - Remover inventário de cliente com sucesso
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de remover o inventário de um cliente existente
    ENTÃO o sistema deve remover o inventário do cliente com sucesso


POSITIVE - Remover produto de todos inventários
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de remover um produto de todos os inventários
    ENTÃO o sistema deve remover todos produtos dos inventários com sucesso


NEGATIVE - Remoção múltipla com dados inválidos
    DADO que o usuário possui um token de autenticação válido
    QUANDO ele faz a requisição de remoção múltipla com dados inválidos
    ENTÃO o sistema deve retornar erro de dados inválidos