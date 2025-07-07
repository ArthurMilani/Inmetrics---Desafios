*** Settings ***
Library  RequestsLibrary
Library  String

*** Variables ***
${HOST}  http://172.23.208.1/address


*** Keywords ***
Verificar saúde
    GET  url=${HOST}/health

Buscar enderecos no sistema
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=    GET  url=${HOST}/fetch  headers=${headers}

    RETURN  ${response}

Buscar endereco com id ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=    GET  url=${HOST}/fetch/${id}  headers=${headers}  expected_status=Anything

    RETURN  ${response}
        
Criar endereco
    [Arguments]  ${client_id}  ${CEP}  ${street}  ${number}  ${city}  ${state}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  client_id=${client_id}  CEP=${CEP}  street=${street}  number=${number}  city=${city}  state=${state}
    ${response}=  POST  url=${HOST}/create  headers=${headers}  json=${body}  expected_status=Anything
    RETURN  ${response}

Atualizar endereco
    [Arguments]  ${id}  ${client_id}  ${CEP}  ${street}  ${number}  ${city}  ${state}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  client_id=${client_id}  CEP=${CEP}  street=${street}  number=${number}  city=${city}  state=${state}
    ${response}=  PUT  url=${HOST}/update/${id}  headers=${headers}  json=${body}  expected_status=Anything
    RETURN  ${response}

Deletar endereco
    [Arguments]  ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  DELETE  url=${HOST}/delete/${id}  headers=${headers}
    RETURN  ${response}
