*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR

*** Variables ***
${products_url}  http://localhost:5001/products

*** Keywords ***
Verificar saúde
    GET  url=${products_url}/health

Buscar catálogo de produtos
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  GET  url=${products_url}/fetch  headers=${headers}

    RETURN  ${response}

Buscar produto com id ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=    GET  url=${products_url}/fetch/${id}  headers=${headers}  expected_status=Anything

    RETURN  ${response}
        
Criar produto
    [Arguments]  
    ...    ${name}=None  
    ...    ${description}=None  
    ...    ${price}=None  
    ...    ${quantity}=None  
    ...    ${status}=None
    
    ${name}=          Run Keyword If    '${name}' == 'None'          FakerLibrary.Name    ELSE    Set Variable    ${name}
    ${description}=   Run Keyword If    '${description}' == 'None'   FakerLibrary.Text    ELSE    Set Variable    ${description}
    ${price}=         Run Keyword If    '${price}' == 'None'         FakerLibrary.Pyfloat    min_value=1.0   max_value=1000.0   right_digits=2    ELSE    Set Variable    ${price}
    ${quantity}=      Run Keyword If    '${quantity}' == 'None'      FakerLibrary.Pyint    min_value=1   max_value=1000     ELSE    Set Variable    ${quantity}
    ${status}=        Run Keyword If    '${status}' == 'None'        FakerLibrary.Pybool  ELSE    Set Variable    ${status}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  name=${name}  description=${description}  price=${price}  quantity=${quantity}  status=${status}
    ${response}=  POST  url=${products_url}/create  headers=${headers}  json=${body}  expected_status=Anything
    Log  Response: ${response.json()} - Status Code: ${response.status_code}
    RETURN  ${response}

Atualizar produto
    [Arguments]  
    ...    ${id}
    ...    ${name}=None  
    ...    ${description}=None  
    ...    ${price}=None  
    ...    ${quantity}=None  
    ...    ${status}=None
    
    ${name}=          Run Keyword If    '${name}' == 'None'          FakerLibrary.Name    ELSE    Set Variable    ${name}
    ${description}=   Run Keyword If    '${description}' == 'None'   FakerLibrary.Text    ELSE    Set Variable    ${description}
    ${price}=         Run Keyword If    '${price}' == 'None'         FakerLibrary.Pyfloat  min_value=1.0   max_value=1000.0   right_digits=2    ELSE    Set Variable    ${price}
    ${quantity}=      Run Keyword If    '${quantity}' == 'None'      FakerLibrary.Pyint    min_value=1   max_value=1000     ELSE    Set Variable    ${quantity}
    ${status}=        Run Keyword If    '${status}' == 'None'        FakerLibrary.Pybool  ELSE    Set Variable    ${status}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  name=${name}  description=${description}  price=${price}  quantity=${quantity}  status=${status}
    ${response}=  PUT  url=${products_url}/update/${id}  headers=${headers}  json=${body}  expected_status=Anything
    RETURN  ${response}

Deletar produto
    [Arguments]  ${id}
    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  DELETE  url=${products_url}/delete/${id}  headers=${headers}
    RETURN  ${response}
