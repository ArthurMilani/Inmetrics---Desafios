from app import app
import jwt
from config import logging
from flask import jsonify, request
from user import user_bp


#Blueprint with endponts
app.register_blueprint(user_bp)

#Validate the Bearer Token
@app.before_request
def validate_token():

    #Log the request details
    logging.info(f"Request: {request.method} {request.url}")
    logging.info(f"Headers: {request.headers}")
    logging.info(f"Body: {request.get_data(as_text=True)}")

    if True: #request.endpoint == 'user.login' or request.endpoint == 'user.health': #The login and health endpoint do not require authentication
        return
    
    _auth_header = request.headers.get('Authorization', None)
    
    if not _auth_header or not _auth_header.startswith("Bearer "):
        return jsonify({"msg": "Empty or not valid header"}), 401

    token = _auth_header.split(" ")[1]
    try:
        jwt.decode(token, app.config['SECRET_KEY'], algorithms=['HS256']) #Token validation returns exception when it fails
    except jwt.InvalidTokenError as e:
        print("Error validating token: ", e)
        return jsonify({"msg": "Invalid or expired token. Please, log in again"}), 401
    except Exception as e:
        print("Error:", e)
        return jsonify({"msg": "Internal Server Error"}), 500
    
@app.after_request
def log_response_info(response):
    logging.info(f"Resposta: status {response.status_code}")
    logging.info(f"Response body: {response.get_data(as_text=True)}")
    return response


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=False, port=5003)


