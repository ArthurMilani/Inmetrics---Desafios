import pymysql
import pymysql.cursors
import requests
import os
from app import app
from pathlib import Path
from config import mysql
from flask import jsonify
from flask import request, Blueprint
from dotenv import load_dotenv

inventory_bp = Blueprint("inventory", __name__)
CLIENTS_API_URL = "http://localhost:5000/clients"
PRODUCTS_API_URL = "http://localhost:5001/products"
ACCESS_TOKEN = "660265208787165882538350202289784386562"


#Create a relation between a product and a client
@inventory_bp.route("/inventory/add_product", methods=['POST'])
def create():
    con = cur= None
    try:
        _json = request.json
        _client_id = _json['client_id']
        _product_id = _json['product_id']
        _number_of_items = _json['number_of_items']
        _purchase_date = _json['purchase_date']

        if not isinstance(_client_id, int) or not isinstance(_product_id, int) or not isinstance(_number_of_items, int) or not isinstance(_purchase_date, str):
            print("Invalid data types")
            return jsonify({'msg': 'Invalid data types'}), 400
        
        if _client_id < 0 or _product_id < 0 or _number_of_items < 0:
            print("Negative values are not allowed")
            return jsonify({'msg': 'Negative values are not allowed'}), 400

        product_exists = verify_product_id(_product_id)
        client_exists  = verify_client_id(_client_id)

        #Verify if product and client are in database before registering the relation        
        if not product_exists['status']:
            return jsonify({"msg": "Product_id does not exist!"}), 404
        
        if not client_exists['status']:
            return jsonify({"msg": "Client_id does not exist!"}), 404
            
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "INSERT INTO client_products (client_id, product_id, product_name, number_of_items, purchase_date) VALUES (%s, %s, %s, %s, %s)"
        bindData = (_client_id, _product_id, product_exists['product_name'], _number_of_items, _purchase_date)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success adding the product to the inventory", "id": cur.lastrowid})
        response.status_code = 201
        return response

    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except RuntimeError as e:
        print("RuntimeError: ", e)
        return jsonify({'msg': 'Error verifying client or product ID'}), 500
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error adding product to the inventory'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Send request to the client context in order to verify if it exists
def verify_client_id(_client_id):
    url = f"{CLIENTS_API_URL}/exists/{_client_id}"
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        raise RuntimeError(f"Failed to verify client ID: {response.status_code} - {response.text}")
    return response.json()


#Send request to the product context in order to verify if it exists
def verify_product_id(_product_id):
    url = f"{PRODUCTS_API_URL}/exists/{_product_id}"
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        raise RuntimeError(f"Failed to verify product ID: {response.status_code} - {response.text}")
    return response.json()


#List the product IDs of some client
@inventory_bp.route("/inventory/list_products_id/<int:client_id>")
def list_products_id(client_id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT id, purchase_date, product_id, product_name, number_of_items FROM client_products WHERE client_id = %s"
        cur.execute(sqlQuery, (client_id))
        con.commit()
        product_ids = cur.fetchall()
        response = jsonify(product_ids)
        response.status_code = 200
        return response
    except Exception as e:
        print("Error: ", e)
        return jsonify({"msg": "Error fetching the products of this client"}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Remove product from inventory
@inventory_bp.route("/inventory/remove_product/<int:id>", methods=['DELETE'])
def remove_product(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor()
        sqlQuery = "DELETE FROM client_products WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        con.commit()
        response = jsonify({"msg":"Success removing the product from your inventory"})
        response.status_code = 200
        return response
        
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error removing the product'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Remove all products related to some ID
@inventory_bp.route("/inventory/remove_products", methods=['DELETE'])
def remove_products():
    con = cur = None
    try:
        _json = request.json
        _remotion_id = _json['remotion_id']
        _type = _json['type']

        if not isinstance(_remotion_id, int) or _type not in ['product', 'client']:
            return jsonify({'msg': 'Invalid data types. type must be either "product" or "client"'}), 400
        
        if _remotion_id < 0:
            print("Negative values are not allowed")
            return jsonify({'msg': 'Negative values are not allowed'}), 400

        con = mysql.connect()
        cur = con.cursor()

        if _type == 'product':
            sqlQuery = "DELETE FROM client_products WHERE product_id = %s"
        elif _type == 'client':
            sqlQuery = "DELETE FROM client_products WHERE client_id = %s"

        cur.execute(sqlQuery, (_remotion_id,))
        con.commit()
        response = jsonify({"msg":"Success removing the products from your inventory"})
        response.status_code = 200
        return response
    
    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error removing products'})

    finally:
        if cur: cur.close()
        if con: con.close()


#Cheack service health
@inventory_bp.route('/inventory/health', methods=['GET'])
def health():
    try:
        return jsonify({"msg": "Inventory service is running"}), 200
    except Exception as e:
        return jsonify({"msg": "Internal Server Error"}), 500
