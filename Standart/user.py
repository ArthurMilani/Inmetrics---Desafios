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


@user_bp.route('/user/login', methods=['POST'])
def login():
    try: 
        _auth = request.authorization
        
        if not _auth or not _auth.username or not _auth.password:
            return jsonify({"Error": "Login data necessary"}), 401    
        
        #Busca usuário no DB
        user = get_user(_auth.username)

        #Verifica existência do usuário
        if user == None or not check_password_hash(user['password'], _auth.password):
            return jsonify({"Error": "Bad username or password"}), 401
        
        #Geração de token de sessão
        token = generate_token(_auth.username)

        return jsonify({"msg": "Success", "token": token}), 200

    except Exception as e:
        print("Error in during login: ", e)
        


@user_bp.route('/user/create', methods=['POST'])
def create():
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
            return jsonify("User successfully created"), 200

    except Exception as e:
        print("Error creating user: ", e)

    finally:
        con.close()
        cur.close()

#Obter usuário pelo username
def get_user(username):
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

#Gerador de hash da senha 
def generate_password(password):
    hash = generate_password_hash(password)
    return hash

#Gerador de token aleatório com jwt
def generate_token(username):
    token = jwt.encode({"username": username, "exp": datetime.datetime.now() + datetime.timedelta(hours=24)}, app.config['SECRET_KEY'])
    return token
