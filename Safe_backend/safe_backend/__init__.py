"""Safe Backend package initializer."""
import flask
from flask_cors import CORS
import psycopg2

app = flask.Flask(__name__)
CORS(app)
app.config.from_object("safe_backend.config")
app.config.from_envvar("SAFE_BACKEND_SETTINGS", silent=True)

# Set up database if it doesn't exist
conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
cur = conn.cursor()

# TODO - Add the other needed databases
cur.execute (
    "CREATE TABLE IF NOT EXISTS vehicles (vehicle_id SERIAL PRIMARY KEY, vehicle_name TEXT NOT NULL, capacity INTEGER NOT NULL, vrange INTEGER NOT NULL);"
)
cur.execute (
    "CREATE TABLE IF NOT EXISTS locations (loc_id SERIAL PRIMARY KEY, loc_name TEXT NOT NULL, lat REAL NOT NULL, long REAL NOT NULL, isPickup BOOLEAN, isDropoff BOOLEAN);"
)
conn.commit()
cur.close()
conn.close()

import safe_backend.api
import safe_backend.views 