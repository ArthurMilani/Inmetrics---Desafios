import requests
import time
from requests.auth import HTTPBasicAuth

auth_token = None
URL = "http://192.168.0.51/%s/health"
SERVICES = [
    "user",
    "products",
    "clients",
    "inventory",
]

def tests():
    print("\nRunning health tests...\n")
    for service in SERVICES:
        health_request(service)
    print("\nHealth tests completed.\n")
    
    print("\nRunning login tests...\n")
    login_test()
    print("\nLogin test completed.\n")

    print("\nRunning Endpoints Tests\n")
    client_id = request_test("clients/create", "post", {"name": "Joao", "email": "Jo9199@inmetrocs.com", "cpf": "239.134.555-19", "balance": 30.25})
    if client_id:
        request_test(f"clients/fetch/{client_id}", "get")
        request_test(f"clients/update/{client_id}", "put", {"name": "Jo Silva", "email": "afa@inmetrics.com", "cpf": "123.194.555-19", "balance": 50.00})
        address_id = request_test(f"address/create", "post", {"client_id": client_id, "street": "Rua Teste", "number": 123, "city": "Testopolis", "state": "TS", "CEP": "00000-000"})
        if address_id:
            request_test(f"address/fetch/{client_id}", "get")
            request_test(f"address/update/{address_id}", "put", {"street": "Rua Atualizada", "number": 456, "city": "Atualizopolis", "state": "AT", "CEP": "87654-321"})
            request_test(f"address/delete/{address_id}", "delete")

    product_id = request_test("products/create", "post", {"name": "Produt Teste", "description": "Um produto para testes", "price": 99.99, "quantity": 10, "status": True})
    if product_id:
        request_test(f"products/fetch/{product_id}", "get")
        request_test(f"products/update/{product_id}", "put", {"name": "Prodto Atualizado", "description": "Um produto atualizado para testes", "price": 89.99, "quantity": 5, "status": True})
    
    if client_id and product_id:
        item_id = request_test("inventory/add_product", "post", {"product_id": product_id, "client_id": client_id, "number_of_items": 2, "purchase_date": "2024-11-01T10:30:00"})
        if item_id:
            request_test(f"inventory/list_products_id/{client_id}", "get")
            #request_test(f"inventory/update/{item_id}", "put", {"product_id": product_id, "client_id": client_id, "number_of_items": 3, "purchase_date": "2024-11-02T10:30:00"})
            request_test(f"inventory/remove_product/{item_id}", "delete")
        request_test(f"clients/delete/{client_id}", "delete")
        request_test(f"products/delete/{product_id}", "delete")

    print("\nEndpoints tests completed.\n")

def health_request(service_name):
    try:
        url = URL % service_name
        response = requests.get(url, timeout=15)
        if response.status_code == 200:
            print(f"[{time.ctime()}] SUCCESS: {service_name} is up")
        else:
            print(f"[{time.ctime()}] WARNING: {service_name} returned status {response.status_code} with message: {response.text}")
    except requests.RequestException as e:
        print(f"[{time.ctime()}] ERROR: {service_name} - {e}")


def login_test():
    USER = "Arthur"
    PASSWORD = "Testando"
    try:
        url = "http://192.168.0.51/user/login"
        auth = HTTPBasicAuth(USER, PASSWORD)
        response = requests.post(url, auth=auth, timeout=15)
        
        # If the user does not exist, create it
        if response.status_code == 401:
            print("Creating user for login test...")
            response = requests.post("http://192.168.0.51/user/create", json={"username": USER, "password": PASSWORD}, timeout=15)
            if response.status_code == 201:
                print(f"[{time.ctime()}] SUCCESS: User created for login test")
            response = requests.post(url, auth=auth, timeout=15)

        if response.status_code == 200:
            global auth_token 
            auth_token = response.json().get("token")
            print(f"[{time.ctime()}] SUCCESS: Login test passed")
        else:
            print(f"[{time.ctime()}] WARNING: Login test failed with status {response.status_code} and message: {response.text}")
    except requests.RequestException as e:
        print(f"[{time.ctime()}] ERROR: Login test failed - {e}")


def request_test(uri, type, json = None):
    try:
        base_url = "http://192.168.0.51/%s"
        id = None
        headers = {
            "Authorization": f"Bearer {auth_token}",
            "Content-Type": "application/json"
        }

        url = base_url % uri

        if type == "get":
            response = requests.get(url, json=json, headers=headers, timeout=15)
        elif type == "post":
            response = requests.post(url, json=json, headers=headers, timeout=15)
            id = response.json().get("id", None)
        elif type == "put":
            response = requests.put(url, json=json, headers=headers, timeout=15)
        elif type == "delete":
            response = requests.delete(url, json=json, headers=headers, timeout=15)

        if response.status_code == 200 or response.status_code == 201:
            print(f"[{time.ctime()}] SUCCESS: {uri} endpoint is up")
            return id
        else:
            print(f"[{time.ctime()}] WARNING: {uri} endpoint returned status {response.status_code} with message: {response.text}")



    except requests.RequestException as e:
        print(f"[{time.ctime()}] ERROR: Test failed - {e}")



if __name__ == "__main__":
    tests()


