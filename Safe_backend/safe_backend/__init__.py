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
# Refers to the different services used by this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS services ( \
        service_id SERIAL PRIMARY KEY, \
        service_name TEXT NOT NULL, \
        start_time TIME NOT NULL, \
        end_time TIME NOT NULL, \
        provider TEXT NOT NULL, \
        cost REAL NOT NULL \
    );"
)

# Refers to the vehicles used by this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS vehicles ( \
        vehicle_id SERIAL PRIMARY KEY, \
        vehicle_name TEXT NOT NULL, \
        capacity INTEGER NOT NULL, \
        vrange INTEGER NOT NULL \
    );"
)

# Refers to the locations registered by this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS locations ( \
        loc_id SERIAL PRIMARY KEY, \
        loc_name TEXT NOT NULL, \
        lat REAL NOT NULL, \
        long REAL NOT NULL, \
        isPickup BOOLEAN, \
        isDropoff BOOLEAN, \
        service_name TEXT REFERENCES services(service_name) \
    );"
)

# Refers to the service ranges for this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS ranges ( \
        range_id SERIAL PRIMARY KEY, \
        lat REAL NOT NULL, \
        long REAL NOT NULL, \
        radius_miles REAL NOT NULL, \
        isPickup BOOLEAN, \
        isDropoff BOOLEAN, \
        service_id INTEGER REFERENCES services(service_id) \
    );"
)

# Refers to the service ranges for this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS users ( \
        user_id SERIAL PRIMARY KEY, \
        first_name TEXT NOT NULL, \
        last_name TEXT NOT NULL, \
        phone_number TEXT NOT NULL, \
        email TEXT NOT NULL \
    );"
)

# Stores the rides booked in this service
cur.execute (
    "CREATE TABLE IF NOT EXISTS ride_requests ( \
        ride_id SERIAL PRIMARY KEY, \
        pickup_lat REAL NOT NULL, \
        pickup_long REAL NOT NULL, \
        dropoff_lat REAL, \
        dropoff_long REAL, \
        user_id INTEGER REFERENCES users(uuid), \
        vehicle_id INTEGER REFERENCES vehicles(vehicle_id), \
        status TEXT, \
        pickup_time TIMESTAMP, \
        dropoff_time TIMESTAMP, \
        service_id INTEGER REFERENCES services(service_id) \
    );"
)
conn.commit()
cur.close()
conn.close()

import safe_backend.api
import safe_backend.views 