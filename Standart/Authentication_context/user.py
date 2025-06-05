import pymysql
import pymysql.cursors
import jwt
import datetime
import pymysql
import pymysql.cursors
from app import app
from config import mysql
from flask import jsonify, request, Blueprint
from werkzeug.security import generate_password_hash, check_password_hash


user_bp = Blueprint("user", __name__)

#Login
@user_bp.route('/user/login', methods=['POST'])
def login():
    try: 
        _auth = request.authorization
        
        if not _auth or not _auth.username or not _auth.password:
            return jsonify({"msg": "Login credentials are necessary"}), 401    
        
        user = get_user(_auth.username)

        #Verify username and password hash
        if user == None or not check_password_hash(user['password'], _auth.password):
            return jsonify({"msg": "Bad username or password"}), 401 
        
        token = generate_token(_auth.username)

        return jsonify({"msg": "Success logging in", "token": token}), 200

    except Exception as e:
        print("Error in during login: ", e)
        return jsonify({"msg": "Internal Server Error"}), 500


#User registration
@user_bp.route('/user/create', methods=['POST'])
def create():
    con = cur = None
    try:
        _json = request.json
        _username = _json['username']
        _password = _json['password']

        if _username and _password:
            con = mysql.connect()
            cur = con.cursor(pymysql.cursors.DictCursor)
            _password = generate_password(_password)
            sqlQuery = "INSERT INTO user (username, password) VALUES (%s, %s)"
            bindData = (_username, _password)
            cur.execute(sqlQuery, bindData)
            con.commit()
            return jsonify({"msg":"User successfully created"}), 201

    except KeyError as e:
        print("KeyError: ", e)
        return jsonify({"msg": "Missing username or password"}), 400
    except Exception as e:
        print("Error creating user: ", e)
        if "Duplicate entry" in str(e):
            return jsonify({"msg": "This username already exists"}), 409
        
        return jsonify({"msg": "Internal Server Error"}), 500

    finally:
        con.close()
        cur.close()


#Cheack service health
@user_bp.route('/user/health', methods=['GET'])
def health():
    try:
        return jsonify({"msg": "User service is running"}), 200
    except Exception as e:
        return jsonify({"msg": "Internal Server Error"}), 500


#Get user by username from database
def get_user(username):
    con = cur = None
    try:
        con = mysql.connect()
        cur = con.cursor(pymysql.cursors.DictCursor)
        sqlQuery = "SELECT * FROM user WHERE username = %s"
        cur.execute(sqlQuery, (username,))
        row = cur.fetchone()
        return row

    except Exception as e:
        print("Error getting user: ", e)

    finally:
        con.close()
        cur.close()

#Password hash generator
def generate_password(password):
    hash = generate_password_hash(password)
    return hash

#Random JWT token generator
def generate_token(username):
    token = jwt.encode({"username": username, "exp": datetime.datetime.now() + datetime.timedelta(hours=24)}, app.config['SECRET_KEY'])
    return token
