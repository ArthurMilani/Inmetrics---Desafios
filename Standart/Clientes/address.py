import pymysql
import pymysql.cursors
import re
from config import mysql
from flask import jsonify
from flask import flash, request, Blueprint

address_bp = Blueprint('address', __name__)


#Address creation
@address_bp.route('/address/create', methods=['POST'])
def create():
    con = cur = None
    try:
        _json = request.json
        _client_id = _json['client_id']
        _state = _json['state']
        _city = _json['city']
        _street = _json['street']
        _number = _json['number']
        _cep = _json['CEP']

        if not isinstance(_client_id, int) or not isinstance(_state, str) or not isinstance(_city, str) or not isinstance(_street, str) or not isinstance(_number, int) or not isinstance(_cep, str):
            return jsonify({'msg': 'Invalid data types'}), 400
        
        if not validate_cep(_cep):
            return jsonify({'msg': 'Invalid CEP format'}), 400
        
        if len(_state) != 2:
            return jsonify({'msg': 'Invalid state'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "INSERT INTO address (client_id, state, city, street, number, CEP) VALUES (%s, %s, %s, %s, %s, %s);"
        bindData = (_client_id, _state, _city, _street, _number, _cep)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg": "Success creating address", "id": cur.lastrowid})
        response.status_code = 201
        return response
    except pymysql.err.IntegrityError as e:
        if "Cannot add or update a child row" in str(e):
            return jsonify({'msg': 'Client ID does not exist'}), 404
    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error creating address'}), 500
    
    finally:
        if cur: cur.close()
        if con: con.close()


#Update one address data
@address_bp.route('/address/update/<int:id>', methods=['PUT'])
def update(id):
    con = cur = None
    try:
        _json = request.json
        _state = _json['state']
        _city = _json['city']
        _street = _json['street']
        _number = _json['number']
        _cep = _json['CEP']

        if not isinstance(_state, str) or not isinstance(_city, str) or not isinstance(_street, str) or not isinstance(_number, int) or not isinstance(_cep, str):
            return jsonify({'msg': 'Invalid data types'}), 400
        
        if not validate_cep(_cep):
            return jsonify({'msg': 'Invalid CEP format'}), 400
        
        if len(_state) != 2:
            return jsonify({'msg': 'Invalid state'}), 400

        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "UPDATE address SET state = %s, city = %s, street = %s, number = %s, CEP = %s WHERE id = %s;"
        bindData = (_state, _city, _street, _number, _cep, id)
        cur.execute(sqlQuery, bindData)
        con.commit()
        response = jsonify({"msg":"Success updating address"})
        response.status_code = 200
        return response

    except pymysql.err.IntegrityError as e:
        if "Cannot add or update a child row" in str(e):
            return jsonify({'msg': 'Client ID does not exist'}), 404
    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({'msg': 'Missing required fields'}), 400
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error updating address data'})
    
    finally:
        if cur: cur.close()
        if con: con.close()

    
def validate_cep(_cep):
    CEP_REGEX = r'^\d{5}-\d{3}$'
    return re.fullmatch(CEP_REGEX, _cep)


#Fetch all addresses from database
@address_bp.route('/address/fetch')
def fetch():
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM address"
        cur.execute(sqlQuery)
        rows = cur.fetchall()
        response = jsonify(rows)
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching address'}), 500

    finally:
        if cur: cur.close()
        if con: con.close()


#Fetch a specific address by client_id
@address_bp.route('/address/fetch/<int:client_id>')
def fetch_all(client_id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM address WHERE client_id = %s"
        cur.execute(sqlQuery, (client_id,))
        rows = cur.fetchall()
        response = jsonify(rows)
        response.status_code = 200
        return response

    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error fetching address'}), 500

    finally:
        if cur: cur.close()
        if con: con.close()


#Delete a specific address
@address_bp.route('/address/delete/<int:id>', methods=['DELETE'])
def delete(id):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "DELETE FROM address WHERE id = %s"
        cur.execute(sqlQuery, (id,))
        con.commit()
        response = jsonify("Success")
        response.status_code = 200
        return response
        
    except Exception as e:
        print("Error: ", e)
        return jsonify({'msg': 'Error deleting address'}), 500

    finally:
        if cur: cur.close()
        if con: con.close()




    
