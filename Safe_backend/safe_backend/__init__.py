"""Safe Backend package initializer."""
import flask
from flask_cors import CORS
import psycopg2
from dotenv import load_dotenv

app = flask.Flask(__name__)
CORS(app)
app.config.from_object("safe_backend.config")
app.config.from_envvar("SAFE_BACKEND_SETTINGS", silent=True)
# load the .env file for the keys
load_dotenv()

# Set up database if it doesn't exist
conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
cur = conn.cursor()

# TODO - Add the other needed databases
# Refers to the different services used by this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS services ( \
        service_name TEXT PRIMARY KEY, \
        start_time TIME NOT NULL, \
        end_time TIME NOT NULL, \
        provider TEXT NOT NULL, \
        cost REAL NOT NULL \
    );"
)

# Refers to the vehicles used by this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS vehicles ( \
        vehicle_name TEXT PRIMARY KEY, \
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
        service_name TEXT REFERENCES services(service_name) \
    );"
)

# Refers to the service ranges for this agency
cur.execute (
    "CREATE TABLE IF NOT EXISTS users ( \
        uuid TEXT PRIMARY KEY, \
        display_name TEXT NOT NULL, \
        phone_number TEXT, \
        email TEXT NOT NULL \
    );"
)

# FAQs for this service
cur.execute (
    "CREATE TABLE IF NOT EXISTS faqs ( \
        question_id SERIAL PRIMARY KEY, \
        service_name TEXT REFERENCES services(service_name), \
        question TEXT NOT NULL, \
        answer TEXT NOT NULL \
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
        user_id TEXT REFERENCES users(uuid), \
        vehicle_name TEXT REFERENCES vehicles(vehicle_name), \
        status TEXT, \
        pickup_time TIMESTAMPTZ, \
        dropoff_time TIMESTAMPTZ, \
        request_time TIMESTAMPTZ, \
        service_name TEXT REFERENCES services(service_name) \
    );"
)
conn.commit()
cur.close()
conn.close()

import safe_backend.api #pylint: disable=wrong-import-position
