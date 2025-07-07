*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR
Resource   ../pages_/clients.robot


*** Keywords ***
QUANDO ele faz a requisição de criar um cliente no sistema com dados corretos
    ${response}=  Criar cliente
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve salvar o cliente no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  201

QUANDO ele faz a requisição de criar um cliente no sistema com dados inválidos
    ${response}=  Criar cliente  name=  email=invalid-email  cpf=12345678901  balance=-100.00
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de dados inválidos
    Should Be Equal As Integers  ${status_code}  400 

QUANDO ele faz a requisição de criar um cliente no sistema com dados repetidos
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  email=${fake_email}  cpf=${fake_cpf}
    ${client_id}=  Set Variable   ${response.json()['id']}
    ${client_id}=  Set Suite Variable  ${client_id}

    ${response}=  Criar cliente  email=${fake_email}  cpf=${fake_cpf}
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de dados repetidos
    Should Be Equal As Integers  ${status_code}  409

QUANDO ele faz a requisição de atualizar o cliente com dados corretos
    ${response}=  Criar cliente
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Atualizar cliente  id=${client_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para atualização
    END

ENTÃO o sistema deve atualizar os dados do cliente no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de atualizar o cliente com dados inválidos
    ${response}=  Criar cliente
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Atualizar cliente  id=${client_id}  name=  email=invalid-email  cpf=12345678901  balance=-100.00
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para atualização
    END

QUANDO ele faz a requisição de atualizar o cliente com dados repetidos
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response1}=  Criar cliente  email=${fake_email}  cpf=${fake_cpf}
    ${response2}=  Criar cliente
    IF    ${response1.status_code} == 201 and ${response2.status_code} == 201
        ${client_id}=  Set Variable   ${response2.json()['id']}
        ${response}=  Atualizar cliente  id=${client_id}  email=${fake_email}  cpf=${fake_cpf}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar os clientes para atualização
    END


QUANDO ele faz a requisição de buscar um cliente existente no sistema
    ${response}=  Criar cliente
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Buscar cliente com id ${client_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para busca
    END

ENTÃO o sistema deve retornar os dados do cliente com sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de buscar um cliente inexistente no sistema
    ${response}=  Buscar cliente com id 99999999
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar erro de cliente não encontrado
    Should Be Equal As Integers  ${status_code}  404

QUANDO ele faz a requisição de buscar todos os clientes no sistema
    ${response}=  Buscar clientes no sistema
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}

ENTÃO o sistema deve retornar a lista de todos os clientes com sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de deletar um cliente existente no sistema
    ${response}=  Criar cliente
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Deletar cliente  id=${client_id}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para deleção
    END

ENTÃO o sistema deve deletar o cliente do banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de verificar se um cliente existe com ID existente
    ${response}=  Criar cliente
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Verificar existencia de cliente  id=${client_id}
        ${response}=  Set Suite Variable  ${response}
    ELSE
        Fail  Não foi possível criar o cliente para verificação
    END

ENTÃO o sistema deve retornar True e sucesso
    Should Be Equal As Integers  ${response.status_code}  200
    Should Be Equal As Strings  ${response.json()['status']}  True


QUANDO ele faz a requisição de verificar se um cliente existe com ID inexistente
    ${response}=  Verificar existencia de cliente  id=99999999
    ${response}=  Set Suite Variable  ${response}

ENTÃO o sistema deve retornar False e sucesso
    Should Be Equal As Integers  ${response.status_code}  200
    Should Be Equal As Strings  ${response.json()['status']}  False