import pymysql
import pymysql.cursors
import requests
from config import mysql
from flask import jsonify
from flask import flash, request, Blueprint

products_bp = Blueprint("products", __name__)
INVENTORY_API_URL = "http://localhost:5002/inventory"
ACCESS_TOKEN = "660265208787165882538350202289784386562"


#Create one product
@products_bp.route("/products/create", methods=['POST'])
def create():
    con = cur = None
    try:
        _json = request.json
        _name = _json['name']
        _description = _json['description']
        _price = _json['price']
        _quantity = _json['quantity']
        _status = _json['status']

        if not isinstance(_name, str) or not isinstance(_description, str) or not isinstance(_price, (int, float)) or not isinstance(_quantity, int) or not isinstance(_status, bool):
            return jsonify({'msg': 'Invalid data types'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "INSERT INTO products (name, description, price, quantity, status) VALUES (%s, %s, %s, %s, %s);"
        bindData = (_name, _description, _price, _quantity, _status)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success creating the product", "id": cur.lastrowid})
        response.status_code = 201
        return response

    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except pymysql.err.IntegrityError as e:
        if "Duplicate entry" in str(e):
            return jsonify({'msg': 'Product name already exists'}), 409
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error creating the product'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Update one specific product
@products_bp.route('/products/update/<int:id>', methods=['PUT'])
def update(id):
    con = cur = None
    try:
        _json = request.json
        _name = _json['name']
        _description = _json['description']
        _price = _json['price']
        _quantity = _json['quantity']
        _status = _json['status']

        if not isinstance(_name, str) or not isinstance(_description, str) or not isinstance(_price, (int, float)) or not isinstance(_quantity, int) or not isinstance(_status, bool):
            return jsonify({'msg': 'Invalid data types'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "UPDATE products SET name = %s, description = %s, price = %s, quantity = %s, status = %s WHERE id = %s;"
        bindData = (_name, _description, _price, _quantity, _status, id)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success"})
        response.status_code = 200
        return response

    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except pymysql.err.IntegrityError as e:
        if "Duplicate entry" in str(e):
            return jsonify({'msg': 'Product name already exists'}), 409
        # elif "Cannot add or update a child row" in str(e):
        #     return jsonify({'msg': 'Product ID does not exist'}), 404
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error updating product'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Fetch a specific product
@products_bp.route("/products/fetch/<int:id>")
def fetch(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM products WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        row = cur.fetchone()

        if not row:
            return jsonify({"msg": "Product not found"}), 404
               
        response = jsonify(row)
        response.status_code = 200
        return response


    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching the product'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Fetch all products
@products_bp.route("/products/fetch")
def fetch_all():
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM products"
        cur.execute(sqlQuery)
        rows = cur.fetchall()
        response = jsonify(rows)
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching all products'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Delete a product
@products_bp.route('/products/delete/<int:id>', methods=['DELETE'])
def delete(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "DELETE FROM products WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        con.commit()
        update_inventories(id)
        response = jsonify({"msg":"Success deleting the product"})
        response.status_code = 200
        return response
        
    except RuntimeError as e:
        print("RuntimeError: ", e)
        return jsonify({'msg': 'Error removing products from inventories'}), 500
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error deleting the product'}), 500
    finally:
        if cur: cur.close()
        if con: con.close()


#Remove the product from inventories
def update_inventories(id):
    url = f"{INVENTORY_API_URL}/remove_products"
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

    body = {
        "remotion_id": id,
        "type": "product"
    }    
    response = requests.delete(url, headers=headers, json=body)
    if response.status_code != 200:
        raise RuntimeError(f"Failed to remove product from inventory: {response.status_code} - {response.text}")


#Verify if a product exists
@products_bp.route('/products/exists/<int:id>')
def product_exists(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT name FROM products WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        name = cur.fetchone()
        if name:
            response = jsonify({"status": True, "product_name": name['name']})
        else:
            response = jsonify({"status": False})
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error verifying if product exists'}), 500

    finally:
        if cur: cur.close()
        if con: con.close()


#Cheack service health
@products_bp.route('/products/health', methods=['GET'])
def health():
    try:
        return jsonify({"msg": "Product service is running"}), 200
    except Exception as e:
        return jsonify({"msg": "Internal Server Error"}), 500