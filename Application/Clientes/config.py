import logging
import os
from dotenv import load_dotenv
from app import app
from flaskext.mysql import MySQL

logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s', 
    datefmt='[%d/%b/%Y %H:%M:%S]'
    )

# with open('/opt/db_host.txt', 'r') as f:
#     db_host = f.read().strip()
load_dotenv()

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = os.getenv('DB_USER')
app.config['MYSQL_DATABASE_PASSWORD'] = os.getenv('DB_PASSWORD')
app.config['MYSQL_DATABASE_DB'] = 'clients_context'
app.config['MYSQL_DATABASE_HOST'] = os.getenv('DB_HOST')
app.config['SECRET_KEY'] = '57840ae5777fc4480db92b598731d686cbcdc3643fa087bdbf26ab347fec5951'
mysql.init_app(app)