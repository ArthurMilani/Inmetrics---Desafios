*** Settings ***
Library  RequestsLibrary
Library  String

*** Variables ***
${login_url}  http://localhost:5003
${USERNAME}  Arthur
${PASSWORD}  Testando


*** Keywords ***
Login Usando Basic Auth E Obter Token
    ${auth}=     Create List    ${USERNAME}    ${PASSWORD}
    Create Session    auth_session    ${login_url}    auth=${auth}
    ${response}=    POST On Session    auth_session    /user/login
    Should Be Equal As Integers    ${response.status_code}    200
    Set Global Variable  ${AUTH_TOKEN}  ${response.json()['token']}