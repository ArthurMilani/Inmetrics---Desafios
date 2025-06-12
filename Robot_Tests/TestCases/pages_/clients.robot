*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR

*** Variables ***
${client_url}  http://localhost:5000/clients

*** Keywords ***
Verificar saúde
    GET  url=${client_url}/health

Buscar clientes no sistema
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  GET  url=${client_url}/fetch  headers=${headers}

    RETURN  ${response}

Buscar cliente com id ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=    GET  url=${client_url}/fetch/${id}  headers=${headers}  expected_status=Anything

    RETURN  ${response}
        
Criar cliente
    [Arguments]  
    ...    ${name}=None
    ...    ${email}=None
    ...    ${cpf}=None  
    ...    ${balance}=None

    ${name}=          Run Keyword If    '${name}' == 'None'     FakerLibrary.Name    ELSE    Set Variable    ${name}
    ${email}=         Run Keyword If    '${email}' == 'None'    FakerLibrary.Email    ELSE    Set Variable    ${email}
    ${cpf}=           Run Keyword If    '${cpf}' == 'None'      FakerLibrary.CPF    ELSE    Set Variable    ${cpf}
    ${balance}=       Run Keyword If    '${balance}' == 'None'  FakerLibrary.Pyfloat  min_value=0.0  max_value=10000.0  right_digits=2  ELSE    Set Variable    ${balance}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  name=${name}  email=${email}  cpf=${cpf}  balance=${balance}
    ${response}=  POST  url=${client_url}/create  headers=${headers}  json=${body}  expected_status=Anything
    RETURN  ${response}

Atualizar cliente
    [Arguments]  
    ...    ${id}
    ...    ${name}=None  
    ...    ${email}=None  
    ...    ${cpf}=None  
    ...    ${balance}=None

    ${name}=          Run Keyword If    '${name}' == 'None'     FakerLibrary.Name    ELSE    Set Variable    ${name}
    ${email}=         Run Keyword If    '${email}' == 'None'    FakerLibrary.Email    ELSE    Set Variable    ${email}
    ${cpf}=           Run Keyword If    '${cpf}' == 'None'      FakerLibrary.CPF    ELSE    Set Variable    ${cpf}
    ${balance}=       Run Keyword If    '${balance}' == 'None'  FakerLibrary.Pyfloat  min_value=0.0  max_value=10000.0  right_digits=2  ELSE    Set Variable    ${balance}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  name=${name}  email=${email}  cpf=${cpf}  balance=${balance}
    ${response}=  PUT  url=${client_url}/update/${id}  headers=${headers}  json=${body}  expected_status=Anything
    RETURN  ${response}

Deletar cliente
    [Arguments]  ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  DELETE  url=${client_url}/delete/${id}  headers=${headers}
    RETURN  ${response}


