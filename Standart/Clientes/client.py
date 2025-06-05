import pymysql
import pymysql.cursors
import requests
import re
from config import mysql
from flask import jsonify
from flask import flash, request, Blueprint

clients_bp = Blueprint("clients", __name__)
INVENTORY_API_URL = "http://localhost:5002/inventory"
ACCESS_TOKEN = "660265208787165882538350202289784386562"


#Create a client
@clients_bp.route('/clients/create', methods=['POST'])
def create():
    con = cur = None
    try:
        _json = request.json
        _name = _json['name']
        _email = _json['email']
        _cpf = _json['cpf']
        _balance = _json['balance']

        if not isinstance(_name, str) or not isinstance(_email, str) or not isinstance(_cpf, str) or not isinstance(_balance, (int, float)):
            return jsonify({'msg': 'Invalid data types'}), 400
        
        if not validate_cpf(_cpf):
            return jsonify({'msg': 'Invalid CPF format'}), 400
        
        if not validate_email(_email):
            return jsonify({'msg': 'Invalid email format'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "INSERT INTO clients (name, email, cpf, balance) VALUES (%s, %s, %s, %s);"
        bindData = (_name, _email, _cpf, _balance)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success creating the client", "id": cur.lastrowid})
        response.status_code = 201
        return response
    
    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except pymysql.err.IntegrityError as e:
        if "Duplicate entry" in str(e):
            return jsonify({'msg': 'Client already exists'}), 409
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error creating the client'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Update a client data
@clients_bp.route("/clients/update/<int:id>", methods=['PUT'])
def update(id):
    con = cur = None
    try:
        _json = request.json
        _name = _json['name']
        _email = _json['email']
        _cpf = _json['cpf']
        _balance = _json['balance']

        if not isinstance(_name, str) or not isinstance(_email, str) or not isinstance(_cpf, str) or not isinstance(_balance, (int, float)):
            return jsonify({'msg': 'Invalid data types'}), 400
        
        if not validate_cpf(_cpf):
            return jsonify({'msg': 'Invalid CPF format'}), 400
        
        if not validate_email(_email):
            return jsonify({'msg': 'Invalid email format'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "UPDATE clients SET name = %s, email = %s, cpf = %s, balance = %s WHERE id = %s;"
        bindData = (_name, _email, _cpf, _balance, id)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success updating the client"})
        response.status_code = 200
        return response

    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except pymysql.err.IntegrityError as e:
        if "Duplicate entry" in str(e):
            return jsonify({'msg': 'Client already exists'}), 409
        # elif "Cannot add or update a child row" in str(e):
        #     return jsonify({'msg': 'Client ID does not exist'}), 404
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error updating the client'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()

def validate_email(_email):
    EMAIL_REGEX = r'^[^@]+@[^@]+\.[^@]+$'
    return re.fullmatch(EMAIL_REGEX, _email)

def validate_cpf(_cpf):
    CPF_REGEX = r'^\d{3}\.\d{3}\.\d{3}\-\d{2}$'
    return re.fullmatch(CPF_REGEX, _cpf)


#Fetch a client by its id
@clients_bp.route("/clients/fetch/<int:id>")
def fetch(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM clients WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        rows = cur.fetchone()

        if rows is None:
            return jsonify({'msg': 'client not found'}), 404
            
        response = jsonify(rows)
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching the client'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Fetch all clients
@clients_bp.route("/clients/fetch")
def fetch_all():
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM clients"
        cur.execute(sqlQuery)
        rows = cur.fetchall()
        response = jsonify(rows)
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching the clients'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Delete a specific client
@clients_bp.route("/clients/delete/<int:id>", methods=['DELETE'])
def delete(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor()
        sqlQuery = "DELETE FROM clients WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        con.commit()
        update_inventory(id)
        response = jsonify({"msg":"Success deleting the client"})
        response.status_code = 200
        return response

    except RuntimeError as e:
        print("RuntimeError: ", e)
        return jsonify({'msg': 'Error removing products from inventory'}), 500
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error deleting the client'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Delete the inventory of this client
def update_inventory(id):
    url = f"{INVENTORY_API_URL}/remove_products"
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

    body = {
        "remotion_id": id,
        "type": "client"
    }
    request = requests.delete(url, headers=headers, json=body)
    if request.status_code != 200:
        raise RuntimeError(f"Failed to remove products from inventory: {request.status_code} - {request.text}")


#Verify if a client exists
@clients_bp.route('/clients/exists/<int:id>')
def client_exists(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT name FROM clients WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        name = cur.fetchone()
        if name:
            response = jsonify({"status":True})
        else:
            response = jsonify({"status":False})
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error verifying if client exists'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Cheack service health
@clients_bp.route('/clients/health', methods=['GET'])
def health():
    try:
        return jsonify({"msg": "Client service is running"}), 200
    except Exception as e:
        return jsonify({"msg": "Internal Server Error"}), 500