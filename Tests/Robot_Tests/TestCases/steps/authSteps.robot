*** Settings ***
Library  RequestsLibrary
Library  String
Library  FakerLibrary    locale=pt_BR
Resource    ../pages_/auth.robot

*** Keywords ***
DADO que o usuário possui um token de autenticação válido
    Login Usando Basic Auth E Obter Token