*** Settings ***
Library    RequestsLibrary
Library    String
Library    FakerLibrary
Resource   ../pages_/clients.robot
Resource   ../pages_/products.robot
Resource   ../pages_/inventory.robot

*** Keywords ***

QUANDO ele faz a requisição de adicionar um item no inventário do cliente com dados corretos
    ${req_client}=  Criar cliente
    ${req_product}=  Criar produto
    IF   ${req_client.status_code} == 201 and ${req_product.status_code} == 201
        ${client_id}=  Set Variable   ${req_client.json()['id']}
        ${product_id}=  Set Variable   ${req_product.json()['id']}
        ${response}=  Adicionar item no inventário  client_id=${client_id}  product_id=${product_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente ou produto para adicionar ao inventário
    END

ENTÃO o sistema deve salvar o item no inventário e retornar sucesso
    Should Be Equal As Integers  ${status_code}  201


QUANDO ele faz a requisição de adicionar um item no inventário do cliente com dados inválidos
    ${req_client}=  Criar cliente
    ${req_product}=  Criar produto
    IF   ${req_client.status_code} == 201 and ${req_product.status_code} == 201
        ${client_id}=  Set Variable   ${req_client.json()['id']}
        ${product_id}=  Set Variable   ${req_product.json()['id']}
        ${response}=  Adicionar item no inventário  client_id=${client_id}  product_id=${product_id}  number_of_items=-10  purchase_date=invalid-date
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente ou produto para adicionar ao inventário
    END

ENTÃO o sistema deve retornar erro de dados inválidos
    Should Be Equal As Integers  ${status_code}  400


QUANDO ele faz a requisição de adicionar um item no inventário com um cliente inexistente
    ${req_product}=  Criar produto
    IF   ${req_product.status_code} == 201
        ${product_id}=  Set Variable   ${req_product.json()['id']}
        ${response}=  Adicionar item no inventário  client_id=${9999999}  product_id=${product_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o produto para adicionar ao inventário
    END

ENTÃO o sistema deve retornar erro de cliente não encontrado
    Should Be Equal As Integers  ${status_code}  404


QUANDO ele faz a requisição de adicionar um item no inventário com um produto inexistente
    ${req_client}=  Criar cliente
    IF   ${req_client.status_code} == 201
        ${client_id}=  Set Variable   ${req_client.json()['id']}
        ${response}=  Adicionar item no inventário  client_id=${client_id}  product_id=${9999999}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para adicionar ao inventário
    END

ENTÃO o sistema deve retornar erro de produto não encontrado
    Should Be Equal As Integers  ${status_code}  404

QUANDO ele faz a requisição de buscar o inventário de um cliente existente
    ${req_client}=  Criar cliente
    IF   ${req_client.status_code} == 201
        ${client_id}=  Set Variable   ${req_client.json()['id']}
        ${response}=  Buscar inventário de cliente  client_id=${client_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para buscar o inventário
    END

ENTÃO o sistema deve retornar o inventário do cliente com sucesso
    Should Be Equal As Integers  ${status_code}  200

QUANDO ele faz a requisição de remover o inventário de um cliente existente
    ${req_client}=  Criar cliente
    ${req1_product}=  Criar produto
    ${req2_product}=  Criar produto
    IF   ${req_client.status_code} == 201 and ${req1_product.status_code} == 201 and ${req2_product.status_code} == 201
        ${client_id}=  Set Variable   ${req_client.json()['id']}
        ${product1_id}=  Set Variable   ${req1_product.json()['id']}
        ${product2_id}=  Set Variable   ${req2_product.json()['id']}
        ${response1}=  Adicionar item no inventário  client_id=${client_id}  product_id=${product1_id}
        ${response2}=  Adicionar item no inventário  client_id=${client_id}  product_id=${product2_id}
        IF    ${response1.status_code} == 201 and ${response2.status_code} == 201
            ${response}=  Remover vários itens do inventário  type=client  remotion_id=${client_id}
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível adicionar os produtos ao inventário do cliente 
        END
    ELSE
        Fail  Não foi possível criar o cliente ou produtos para remover o inventário
    END

ENTÃO o sistema deve remover o inventário do cliente com sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de remover um produto de todos os inventários
    ${req_product}=  Criar produto
    ${req_client1}=  Criar cliente
    ${req_client2}=  Criar cliente
    IF   ${req_product.status_code} == 201 and ${req_client1.status_code} == 201 and ${req_client2.status_code} == 201
        ${product_id}=  Set Variable   ${req_product.json()['id']}
        ${client1_id}=  Set Variable   ${req_client1.json()['id']}
        ${client2_id}=  Set Variable   ${req_client2.json()['id']}
        ${response1}=  Adicionar item no inventário  client_id=${client1_id}  product_id=${product_id}
        ${response2}=  Adicionar item no inventário  client_id=${client2_id}  product_id=${product_id}
        IF    ${response1.status_code} == 201 and ${response2.status_code} == 201
            ${response}=  Remover vários itens do inventário  type=product  remotion_id=${product_id}
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível adicionar o produto ao inventário dos clientes 
        END
    ELSE
        Fail  Não foi possível criar o produto ou clientes para remover o inventário
    END


ENTÃO o sistema deve remover todos produtos dos inventários com sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de remoção múltipla com dados inválidos
    ${response}=  Remover vários itens do inventário  type=invalid_type  remotion_id=invalid_id
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}