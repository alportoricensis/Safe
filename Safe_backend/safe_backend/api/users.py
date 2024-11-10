"""REST API for users."""
import datetime
import flask
import psycopg2
import safe_backend.api.config
from safe_backend.api.requests import RideRequests
from safe_backend.api.utils import *

# Routes
@safe_backend.app.route("/api/v1/users/login/", methods=["POST"])
def login_user():
    # Get uuid from request
    pass_uuid = flask.request.json["uuid"]

    # If this passenger hasn't been seen before, add them to the database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM ride_requests WHERE user_id = %s;", (pass_uuid, ))
    user = cur.fetchone()
    if user is not None:
        display_name = flask.request.json["displayName"]
        email = flask.request.json["email"]
        firstName = display_name.split(" ")[0]
        lastName = display_name.split(" ")[1]
        cur.execute(
            "INSERT INTO users (user_id, first_name, last_name, phone_number, email) VALUES (%s, %s, %s, %s, %s)",
            (pass_uuid, firstName, lastName, "(000) 000-0000", email)
        )
    return flask.jsonify(**{"msg": "Succesfully logged {pass_uuid} in."}), 200


@safe_backend.app.route("/api/v1/users/delete/", methods=["POST"])
def delete_acct():
    pass

@safe_backend.app.route("/api/v1/users/update/", methods=["POST"])
def update_acct():
    pass

@safe_backend.app.route("/api/v1/users/bookings/", methods=["GET"])
def get_bookings():
    # Get UUID from the request
    pass_uuid = flask.request.json["uuid"]

    # Get prior rides from the database
    conn = psycopg2.connect(database="safe_backend", user="safe", password="",
                        port="5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM ride_requests WHERE user_id = %s;", (pass_uuid, ))
    requests = cur.fetchall()
    context = {"requests": []}
    for request in requests:
        context["requests"].append({
            "ride_id": request[0],
            "pickup_lat": request[1],
            "pickup_long": request[2],
            "dropoff_lat": request[3],
            "dropoff_long": request[4],
            "status": request[7],
            "pickup_time": str(request[8]),
            "dropoff_time": str(request[9]),
            "service_name": request[10]
        })
    return flask.jsonify(**context), 200


