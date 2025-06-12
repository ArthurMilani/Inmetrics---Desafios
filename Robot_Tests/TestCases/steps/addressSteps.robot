*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR
Resource    ../pages_/clients.robot
Resource    ../pages_/address.robot
Resource    ../pages_/auth.robot

*** Keywords ***
QUANDO ele faz a requisição de criar um endereço no sistema com dados corretos
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${street}=  FakerLibrary.Street Name
        ${number}=  FakerLibrary.Building Number
        ${cep}=  FakerLibrary.postcode
        ${city}=  FakerLibrary.City
        ${state}=  FakerLibrary.State Abbr
        ${response}=  Criar endereco  client_id=${client_id}  CEP=${cep}  street=${street}  number=${512}  city=${city}  state=${state}
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para criação do endereço
    END

ENTÃO o sistema deve salvar o endereço no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  201
    

QUANDO ele faz a requisição de criar um endereço no sistema com dados inválidos
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${response}=  Criar endereco  client_id=${client_id}  CEP=12345678  street=Rua Inexistente  number=512  city=Cidade Inexistente  state=XX
        ${status_code}=  Set Variable  ${response.status_code}
        ${status_code}=  Set Suite Variable  ${status_code}
    ELSE
        Fail  Não foi possível criar o cliente para criação do endereço inválido
    END

ENTÃO o sistema deve retornar erro de dados inválidos
    Should Be Equal As Integers  ${status_code}  400

QUANDO ele faz a requisição de criar um endereço no sistema com ID de cliente inexistente
    ${response}=  Criar endereco  client_id=${99999999}  CEP=00000-000  street=Rua Inexistente  number=${512}  city=Cidade Inexistente  state=SP
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}


ENTÃO o sistema deve retornar erro de cliente não encontrado
    Should Be Equal As Integers  ${status_code}  404


QUANDO ele faz a requisição de atualizar o endereço com dados corretos
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${street}=  FakerLibrary.Street Name
        ${number}=  FakerLibrary.Building Number
        ${cep}=  FakerLibrary.postcode
        ${city}=  FakerLibrary.City
        ${state}=  FakerLibrary.State Abbr
        ${response}=  Criar endereco  client_id=${client_id}  CEP=00000-000  street=${street}  number=${512}  city=${city}  state=${state}
        IF    ${response.status_code} == 201
            ${address_id}=  Set Variable   ${response.json()['id']}
            ${new_street}=  FakerLibrary.Street Name
            # ${new_number}=  FakerLibrary.Building Number
            ${new_city}=  FakerLibrary.City
            ${new_state}=  FakerLibrary.State Abbr
            ${response}=  Atualizar endereco  id=${address_id}  client_id=${client_id}  CEP=00000-000  street=${new_street}  number=${512}  city=${new_city}  state=${new_state}
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível criar o endereço para atualização do endereço
        END
    ELSE
        Fail  Não foi possível criar o cliente para atualização do endereço
    END

ENTÃO o sistema deve atualizar os dados do endereço no banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200


QUANDO ele faz a requisição de atualizar o endereço com dados inválidos
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${street}=  FakerLibrary.Street Name
        ${number}=  FakerLibrary.Building Number
        ${cep}=  FakerLibrary.postcode
        ${city}=  FakerLibrary.City
        ${state}=  FakerLibrary.State Abbr
        ${response}=  Criar endereco  client_id=${client_id}  CEP=00000-000  street=${street}  number=${512}  city=${city}  state=${state}
        IF    ${response.status_code} == 201
            ${address_id}=  Set Variable   ${response.json()['id']}
            ${response}=  Atualizar endereco  id=${address_id}  client_id=${client_id}  CEP=12345678  street=Rua Inexistente  number=512abc  city=Cidade Inexistente  state=XX
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível criar o endereço para atualização do endereço inválido
        END
    ELSE
        Fail  Não foi possível criar o cliente para atualização do endereço inválido
    END


QUANDO ele faz a requisição de buscar endereços de um cliente
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${street}=  FakerLibrary.Street Name
        ${number}=  FakerLibrary.Building Number
        ${cep}=  FakerLibrary.postcode
        ${city}=  FakerLibrary.City
        ${state}=  FakerLibrary.State Abbr
        ${response}=  Criar endereco  client_id=${client_id}  CEP=00000-000  street=${street}  number=${512}  city=${city}  state=${state}
        IF    ${response.status_code} == 201
            ${address_id}=  Set Variable   ${response.json()['id']}
            ${response}=  Buscar endereco com id ${client_id}
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível criar o endereço para busca do endereço
        END
    ELSE
        Fail  Não foi possível criar o cliente para busca do endereço
    END

ENTÃO o sistema deve retornar os dados dos endereços com sucesso
    Should Be Equal As Integers  ${status_code}  200

QUANDO ele faz a requisição de buscar todos os endereços no sistema
    ${response}=  Buscar enderecos no sistema
    ${status_code}=  Set Variable  ${response.status_code}
    ${status_code}=  Set Suite Variable  ${status_code}


QUANDO ele faz a requisição de deletar um endereço existente no sistema
    ${fake_name}=  FakerLibrary.Name
    ${fake_email}=  FakerLibrary.Email
    ${fake_cpf}=  FakerLibrary.CPF
    ${response}=  Criar cliente  name=${fake_name}  email=${fake_email}  cpf=${fake_cpf}  balance=${1000.00}
    IF    ${response.status_code} == 201
        ${client_id}=  Set Variable   ${response.json()['id']}
        ${street}=  FakerLibrary.Street Name
        ${number}=  FakerLibrary.Building Number
        ${cep}=  FakerLibrary.postcode
        ${city}=  FakerLibrary.City
        ${state}=  FakerLibrary.State Abbr
        ${response}=  Criar endereco  client_id=${client_id}  CEP=00000-000  street=${street}  number=${512}  city=${city}  state=${state}
        IF    ${response.status_code} == 201
            ${address_id}=  Set Variable   ${response.json()['id']}
            ${response}=  Deletar endereco  id=${address_id}
            ${status_code}=  Set Variable  ${response.status_code}
            ${status_code}=  Set Suite Variable  ${status_code}
        ELSE
            Fail  Não foi possível criar o endereço para deleção do endereço
        END
    ELSE
        Fail  Não foi possível criar o cliente para deleção do endereço
    END

ENTÃO o sistema deve deletar o endereço do banco de dados e retornar sucesso
    Should Be Equal As Integers  ${status_code}  200