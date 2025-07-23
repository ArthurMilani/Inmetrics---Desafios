*** Settings ***
Library  RequestsLibrary
Library  String

*** Variables ***
${login_url}  http://172.23.208.1
${USERNAME}  AturM
${PASSWORD}  Testando


*** Keywords ***
Login Usando Basic Auth E Obter Token
    ${auth}=     Create List    ${USERNAME}    ${PASSWORD}
    Create Session    auth_session    ${login_url}    auth=${auth}
    ${response}=    POST On Session    auth_session    /user/login    expected_status=Anything
    IF    ${response.status_code} == 401
        ${header}=    Create Dictionary    content-type=application/json
        ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
        ${response}=   POST  url=${login_url}/user/create  headers=${header}  json=${body}
        Should Be Equal As Integers  ${response.status_code}  201
        ${response}=    POST On Session    auth_session    /user/login
        
    END
    
    Set Global Variable  ${AUTH_TOKEN}  ${response.json()['token']}
    