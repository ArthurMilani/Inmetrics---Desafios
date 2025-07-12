import logging
from app import app
from flaskext.mysql import MySQL

logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s - %(levelname)s - %(message)s', 
    datefmt='[%d/%b/%Y %H:%M:%S]'
    )

with open('/opt/db_host.txt', 'r') as f:
    db_host = f.read().strip()

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'ArthurMilani'
app.config['MYSQL_DATABASE_PASSWORD'] = 'pacote321'
app.config['MYSQL_DATABASE_DB'] = 'products_context'
app.config['MYSQL_DATABASE_HOST'] = db_host
app.config['SECRET_KEY'] = '57840ae5777fc4480db92b598731d686cbcdc3643fa087bdbf26ab347fec5951'
mysql.init_app(app)