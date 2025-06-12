*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR
Resource    ../pages_/products.robot


*** Keywords ***
QUANDO ele faz a requisição de criar um produto no sistema com dados corretos
    ${response}=  Criar produto  
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve salvar o produto no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  201

QUANDO ele faz a requisição de criar um produto no sistema com dados inválidos
    ${response}=  Criar produto  name=  description=Descrição Inválida  price=invalid  quantity=-10  status=${False}
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de dados inválidos
    Should Be Equal As Integers  ${status_code}  400

QUANDO ele faz a requisição de criar um produto no sistema com dados repetidos
    ${fake_name}=  FakerLibrary.Name
    ${response}=  Criar produto  name=${fake_name}
    ${product_id}=  Set Variable   ${response.json()['id']}
    ${product_id}=  Set Suite Variable  ${product_id}

    ${response}=  Criar produto  name=${fake_name}
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de dados repetidos
    Should Be Equal As Integers  ${status_code}  409

QUANDO ele faz a requisição de atualizar o produto com dados corretos
    ${response}=  Criar produto
    IF    ${response.status_code} == 201
        ${product_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Atualizar produto  id=${product_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o produto para atualização
    END

ENTÃO o sistema deve atualizar os dados do produto no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200

QUANDO ele faz a requisição de atualizar o produto com dados inválidos
    ${response}=  Criar produto
    IF    ${response.status_code} == 201
        ${product_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Atualizar produto  id=${product_id}  name=  description=Descrição Inválida  price=invalid  quantity=-10  status=${False}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o produto para atualização
    END

QUANDO ele faz a requisição de buscar um produto existente no sistema
    ${response}=  Criar produto
    IF    ${response.status_code} == 201
        ${product_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Buscar produto com id ${product_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o produto para busca
    END

ENTÃO o sistema deve retornar os dados do produto com sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de buscar todos os produtos no sistema
    ${response}=  Buscar catálogo de produtos
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar a lista de todos os produtos com sucesso
    Should Be Equal As Integers  ${status_code}  200

QUANDO ele faz a requisição de buscar um produto inexistente no sistema
    ${response}=  Buscar produto com id 999999
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de produto não encontrado
    Should Be Equal As Integers  ${status_code}  404

QUANDO ele faz a requisição de deletar um produto existente no sistema
    ${response}=  Criar produto
    IF    ${response.status_code} == 201
        ${product_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Deletar produto  id=${product_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o produto para deleção
    END

ENTÃO o sistema deve deletar o produto do banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200