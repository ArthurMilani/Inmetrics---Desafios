*** Settings ***
Library    RequestsLibrary
Library    String
Library    FakerLibrary

*** Variables ***
${inventory_url}  http://localhost:5002/inventory

*** Keywords ***

Adicionar item no inventário
    [Arguments]
    ...    ${client_id}
    ...    ${product_id}
    ...    ${number_of_items}=None
    ...    ${purchase_date}=2024-11-01T10:30:00

    ${number_of_items}=  Run Keyword If    '${number_of_items}' == 'None'  FakerLibrary.Pyint  min_value=1  max_value=100  ELSE    Set Variable    ${number_of_items}
    # ${purchase_date}=  Run Keyword If    '${purchase_date}' == 'None'  FakerLibrary.DateTime  ELSE    Set Variable    ${purchase_date}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    &{body} =  Create Dictionary  client_id=${client_id}  product_id=${product_id}  number_of_items=${number_of_items}  purchase_date=${purchase_date}
    ${response}=  POST  url=${inventory_url}/add_product  headers=${headers}  json=${body}  expected_status=Anything

    RETURN  ${response}


Buscar inventário de cliente
    [Arguments]  ${client_id}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${response}=  GET  url=${inventory_url}/list_products_id/${client_id}  headers=${headers}  expected_status=Anything

    RETURN  ${response}


Remover vários itens do inventário
    [Arguments]  
    ...    ${type}  
    ...    ${remotion_id}

    &{headers} =  Create Dictionary  content-type=application/json  authorization=Bearer ${AUTH_TOKEN}
    ${body} =  Create Dictionary  type=${type}  remotion_id=${remotion_id}
    ${response}=  DELETE  url=${inventory_url}/remove_products  headers=${headers}  json=${body}  expected_status=Anything

    RETURN  ${response}
    