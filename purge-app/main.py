# python3 -m pip install google-cloud-functions - preinstalled
# pip install "cloud-sql-python-connector[pymysql]"
import os
import json
import functions_framework
from google.cloud.sql.connector import Connector
import sqlalchemy
import pymysql


# [START functions_hello_get]
@functions_framework.http
def hello_get(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    """
    return 'Hello World!'
# [END functions_hello_get]

# [START functions_ghost_posts_get]
@functions_framework.http
def ghost_posts_get(request):
    """ ghost_posts_get function
    To test Cloud SQL connectivity.

    Returns:
        The posts in the DB.  As response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    db_conn_name = os.environ.get("db_conn_name") # e.g. "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
    user = os.environ.get("db_user") # e.g. root
    pwd = os.environ.get("db_pwd")
    db_name = os.environ.get("db_name")  # e.g. ghostdb
    conn_url = 'mysql+pymysql://{}:{}@/{}?unix_socket=/cloudsql/{}'.format(user, pwd, db_name, db_conn_name)
    engine = sqlalchemy.create_engine(conn_url, pool_size=1, max_overflow=0)
    try:
        with engine.connect() as db_conn:
            rows = db_conn.execute("select id, title, author_id, created_at from posts;").fetchall()
            response = json.dumps([dict(row.items()) for row in rows], indent=4, default=str)
            headers = {'Content-Type': 'application/json'}
            print(response)
    except Exception as e:
        return ('Error: {}'.format(str(e)), 500)

    return (response, 200, headers)
# [END functions_ghost_posts_get]

# [START functions_ghost_posts_purge]
@functions_framework.http
def ghost_posts_purge(request):
    """ ghost_posts_purge function
    Purges all the posts in the database.

    Returns:
        A response object, which prints the number of rows deleted.
    """
    db_conn_name = os.environ.get("db_conn_name") # e.g. "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
    user = os.environ.get("db_user") # e.g. root
    pwd = os.environ.get("db_pwd")
    db_name = os.environ.get("db_name")  # e.g. ghostdb
    conn_url = 'mysql+pymysql://{}:{}@/{}?unix_socket=/cloudsql/{}'.format(user, pwd, db_name, db_conn_name)
    engine = sqlalchemy.create_engine(conn_url, echo=True, pool_size=1, max_overflow=0)
    try:
        with engine.connect() as db_conn:
            db_conn.execute("delete from posts_meta;")
            db_conn.execute("delete from posts_tags;")
            db_conn.execute("delete from posts_authors;")
            res = db_conn.execute("delete from posts;")
         
            return (f"{res.rowcount} posts purged.", 200)
    except Exception as e:
        return ('Error: {}'.format(str(e)), 500)
# [END functions_ghost_posts_purge]